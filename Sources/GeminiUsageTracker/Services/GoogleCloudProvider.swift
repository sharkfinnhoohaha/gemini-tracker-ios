import Foundation

public final class GoogleCloudProvider: UsageProvider {
    private let authService: GoogleAuthService
    private let projectId: String
    private let session: URLSession

    public init(authService: GoogleAuthService, projectId: String, session: URLSession = .shared) {
        self.authService = authService
        self.projectId = projectId
        self.session = session
    }

    public func fetchUsageState() async throws -> UsageState {
        let projectBillingInfo = try await fetchProjectBillingBalance(projectId: projectId)

        let billingEnabled = projectBillingInfo.billingEnabled ?? false
        let status: UsageStatus = billingEnabled ? .normal : .highUsage
        let summary = billingEnabled
            ? "Cloud Billing is enabled for project \(projectId)."
            : "Cloud Billing is disabled for project \(projectId)."

        var metadata: [String: String] = [
            "projectId": projectBillingInfo.projectId ?? projectId,
            "billingEnabled": String(billingEnabled)
        ]

        if let account = projectBillingInfo.billingAccountName {
            metadata["billingAccountName"] = account
        }
        if let name = projectBillingInfo.name {
            metadata["resourceName"] = name
        }

        return UsageState(
            source: .googleCloud,
            status: status,
            usagePercentage: billingEnabled ? 0.25 : 0.85,
            summary: summary,
            metadata: metadata
        )
    }

    public func fetchProjectBillingBalance(projectId: String) async throws -> ProjectBillingInfo {
        let token = try await authService.getBearerToken()

        guard let url = URL(string: "https://cloudbilling.googleapis.com/v1/projects/\(projectId)/billingInfo") else {
            throw UsageProviderError.apiError("Failed to build Cloud Billing URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        try validateGoogleAPIResponse(response, data: data)

        guard !data.isEmpty else {
            throw UsageProviderError.emptyData
        }

        do {
            return try JSONDecoder().decode(ProjectBillingInfo.self, from: data)
        } catch {
            throw UsageProviderError.apiError("Unable to decode Cloud Billing response: \(error.localizedDescription)")
        }
    }
}

public struct ProjectBillingInfo: Codable {
    public let name: String?
    public let projectId: String?
    public let billingAccountName: String?
    public let billingEnabled: Bool?

    public init(name: String?, projectId: String?, billingAccountName: String?, billingEnabled: Bool?) {
        self.name = name
        self.projectId = projectId
        self.billingAccountName = billingAccountName
        self.billingEnabled = billingEnabled
    }
}