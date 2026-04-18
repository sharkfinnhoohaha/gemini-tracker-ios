import Foundation

enum PreviewSupport {
    @MainActor
    static func makeSignedOutAuthViewModel() -> AuthViewModel {
        let authService = GoogleAuthService(clientID: "preview-client-id")
        authService.isAuthenticated = false
        authService.userName = nil
        authService.userEmail = nil

        let viewModel = AuthViewModel(authService: authService)
        viewModel.isAuthenticated = false
        viewModel.isLoading = false
        viewModel.error = nil
        return viewModel
    }

    @MainActor
    static func makeAuthenticatedAuthViewModel() -> AuthViewModel {
        let authService = GoogleAuthService(clientID: "preview-client-id")
        authService.isAuthenticated = true
        authService.userName = "Gemini Dev"
        authService.userEmail = "preview@gemini.example"

        let viewModel = AuthViewModel(authService: authService)
        viewModel.isAuthenticated = true
        viewModel.isLoading = false
        viewModel.error = nil
        return viewModel
    }

    @MainActor
    static func makeDashboardViewModel() -> DashboardViewModel {
        let viewModel = DashboardViewModel(apiService: PreviewUsageAPIService())
        viewModel.currentUsage = PreviewData.currentUsage
        viewModel.historicalData = PreviewData.historicalData(days: 7)
        viewModel.usageState = PreviewData.usageState
        viewModel.isLoading = false
        viewModel.errorMessage = nil
        return viewModel
    }

    @MainActor
    static func makeStoreManager(powerUser: Bool = false) -> StoreManager {
        let storeManager = StoreManager()
        storeManager.isPowerUser = powerUser
        storeManager.hasPriorityAlerts = powerUser
        return storeManager
    }

    @MainActor
    static func makeNotificationManager() -> NotificationManager {
        NotificationManager()
    }
}

private struct PreviewUsageAPIService: UsageAPIService {
    func fetchCurrentUsage() async throws -> UsageReport {
        PreviewData.currentUsage
    }

    func fetchHistoricalUsage(days: Int) async throws -> [HistoricalData] {
        PreviewData.historicalData(days: days)
    }

    func fetchUsageState() async throws -> UsageState? {
        PreviewData.usageState
    }
}

private enum PreviewData {
    static let currentUsage = UsageReport(
        modelName: "Gemini 2.5 Pro",
        requestsUsed: 128,
        requestsLimit: 150,
        tokensUsed: 1_420_000,
        tokensLimit: 2_000_000
    )

    static let usageState = UsageState(
        source: .mock,
        status: .highUsage,
        usagePercentage: 0.71,
        summary: "Preview data loaded locally with no network calls.",
        metadata: [
            "source": "preview",
            "mode": "macOS"
        ]
    )

    static func historicalData(days: Int) -> [HistoricalData] {
        let sampleTokens = [920_000, 980_000, 1_030_000, 1_110_000, 1_220_000, 1_320_000, 1_420_000]
        let sampleRequests = [64, 70, 76, 84, 92, 108, 128]
        let count = min(days, sampleTokens.count)
        let startIndex = sampleTokens.count - count
        let calendar = Calendar.current
        let today = Date()

        return (0..<count).compactMap { index in
            let sourceIndex = startIndex + index
            let dayOffset = count - index - 1
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return nil
            }

            return HistoricalData(
                date: date,
                tokensUsed: sampleTokens[sourceIndex],
                requestsUsed: sampleRequests[sourceIndex]
            )
        }
    }
}
