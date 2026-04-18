import Foundation

public enum UsageProviderKind: String {
    case googleCloud
    case gmail
    case mock
}

public enum UsageFactory {
    public static func makeProvider(
        authService: GoogleAuthService,
        projectId: String?,
        preferredKind: UsageProviderKind? = nil
    ) -> UsageProvider {
        let selectedKind = preferredKind ?? providerKindFromEnvironment()

        switch selectedKind {
        case .googleCloud:
            if let projectId, !projectId.isEmpty {
                return GoogleCloudProvider(authService: authService, projectId: projectId)
            }
            return GmailUsageProvider(authService: authService)
        case .gmail:
            return GmailUsageProvider(authService: authService)
        case .mock:
            return MockStateProvider()
        }
    }

    public static func makeAPIService(
        authService: GoogleAuthService,
        projectId: String?,
        preferredKind: UsageProviderKind? = nil
    ) -> UsageAPIService {
        let provider = makeProvider(
            authService: authService,
            projectId: projectId,
            preferredKind: preferredKind
        )
        return ProviderBackedUsageAPIService(provider: provider)
    }

    private static func providerKindFromEnvironment() -> UsageProviderKind {
        let rawValue = ProcessInfo.processInfo.environment["USAGE_PROVIDER"]?.lowercased()
        switch rawValue {
        case "googlecloud", "google_cloud", "cloud", "billing":
            return .googleCloud
        case "gmail", "email":
            return .gmail
        case "mock":
            return .mock
        default:
            return .googleCloud
        }
    }
}

private final class ProviderBackedUsageAPIService: UsageAPIService {
    private let provider: UsageProvider
    private var lastState: UsageState?

    init(provider: UsageProvider) {
        self.provider = provider
    }

    func fetchCurrentUsage() async throws -> UsageReport {
        let state = try await provider.fetchUsageState()
        lastState = state

        let percentage = state.usagePercentage ?? defaultPercentage(for: state.status)
        let normalized = min(max(percentage, 0.0), 1.0)

        let requestsLimit = 100
        let tokensLimit = 2_000_000

        return UsageReport(
            modelName: displayName(for: state.source),
            requestsUsed: Int(normalized * Double(requestsLimit)),
            requestsLimit: requestsLimit,
            tokensUsed: Int(normalized * Double(tokensLimit)),
            tokensLimit: tokensLimit
        )
    }

    func fetchHistoricalUsage(days: Int) async throws -> [HistoricalData] {
        let state = try await provider.fetchUsageState()
        lastState = state
        let percentage = state.usagePercentage ?? defaultPercentage(for: state.status)
        let normalized = min(max(percentage, 0.0), 1.0)

        let calendar = Calendar.current
        let today = Date()
        var history: [HistoricalData] = []

        for offset in stride(from: days - 1, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let drift = Double(offset) / Double(max(days, 1))
                let dayPercentage = max(0.0, min(1.0, normalized - (drift * 0.15)))
                history.append(
                    HistoricalData(
                        date: date,
                        tokensUsed: Int(dayPercentage * 250_000),
                        requestsUsed: Int(dayPercentage * 120)
                    )
                )
            }
        }

        return history
    }

    func fetchUsageState() async throws -> UsageState? {
        if let lastState {
            return lastState
        }
        let state = try await provider.fetchUsageState()
        lastState = state
        return state
    }

    private func defaultPercentage(for status: UsageStatus) -> Double {
        switch status {
        case .normal:
            return 0.30
        case .highUsage:
            return 0.85
        case .exhausted:
            return 1.0
        }
    }

    private func displayName(for source: UsageSource) -> String {
        switch source {
        case .googleCloud:
            return "Google Cloud Billing"
        case .gmail:
            return "Gmail Quota Alerts"
        case .mock:
            return "Mock Usage"
        }
    }
}

private final class MockStateProvider: UsageProvider {
    func fetchUsageState() async throws -> UsageState {
        return UsageState(
            source: .mock,
            status: .highUsage,
            usagePercentage: 0.84,
            summary: "Mock provider active."
        )
    }
}