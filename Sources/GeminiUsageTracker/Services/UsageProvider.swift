import Foundation

public protocol UsageProvider {
    func fetchUsageState() async throws -> UsageState
}

public enum UsageProviderError: LocalizedError {
    case unauthorized
    case forbidden
    case invalidResponse
    case emptyData
    case apiError(String)

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized (401). Please sign in again."
        case .forbidden:
            return "Forbidden (403). Ensure the required Google API is enabled and scopes are granted."
        case .invalidResponse:
            return "Invalid response received from server."
        case .emptyData:
            return "No data was returned by the provider."
        case .apiError(let message):
            return message
        }
    }
}

internal func validateGoogleAPIResponse(_ response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw UsageProviderError.invalidResponse
    }

    switch httpResponse.statusCode {
    case 200...299:
        return
    case 401:
        throw UsageProviderError.unauthorized
    case 403:
        throw UsageProviderError.forbidden
    default:
        let message = String(data: data, encoding: .utf8) ?? "Google API request failed with status code \(httpResponse.statusCode)."
        throw UsageProviderError.apiError(message)
    }
}