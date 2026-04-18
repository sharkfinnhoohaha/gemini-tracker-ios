import Foundation

public final class GmailUsageProvider: UsageProvider {
    private let authService: GoogleAuthService
    private let session: URLSession

    private let usageQuery = "from:google-one-noreply@google.com (\"usage\" OR \"limit\" OR \"80%\") newer_than:30d"

    public init(authService: GoogleAuthService, session: URLSession = .shared) {
        self.authService = authService
        self.session = session
    }

    public func fetchUsageState() async throws -> UsageState {
        let messageIds = try await fetchMessages(query: usageQuery)

        guard let latestMessageId = messageIds.first else {
            return UsageState(
                source: .gmail,
                status: .normal,
                usagePercentage: nil,
                summary: "No recent quota warning emails were found.",
                metadata: ["query": usageQuery]
            )
        }

        let snippet = try await fetchMessageSnippet(messageId: latestMessageId)
        let parsed = parseUsage(from: snippet)

        let status: UsageStatus
        if parsed.isExhausted {
            status = .exhausted
        } else if parsed.percentage.map({ $0 >= 80 }) == true || parsed.isHighUsage {
            status = .highUsage
        } else {
            status = .normal
        }

        return UsageState(
            source: .gmail,
            status: status,
            usagePercentage: parsed.percentage.map { Double($0) / 100.0 },
            summary: snippet,
            metadata: [
                "messageId": latestMessageId,
                "query": usageQuery,
                "parsedPercentage": parsed.percentage.map(String.init) ?? "unknown"
            ]
        )
    }

    private func fetchMessages(query: String) async throws -> [String] {
        let token = try await authService.getBearerToken()

        var components = URLComponents(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: "5")
        ]

        guard let url = components?.url else {
            throw UsageProviderError.apiError("Failed to build Gmail messages URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        try validateGoogleAPIResponse(response, data: data)

        let decoded = try JSONDecoder().decode(GmailListResponse.self, from: data)
        return decoded.messages?.map(\.id) ?? []
    }

    private func fetchMessageSnippet(messageId: String) async throws -> String {
        let token = try await authService.getBearerToken()

        var components = URLComponents(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageId)")
        components?.queryItems = [URLQueryItem(name: "format", value: "metadata")]

        guard let url = components?.url else {
            throw UsageProviderError.apiError("Failed to build Gmail message URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        try validateGoogleAPIResponse(response, data: data)

        let decoded = try JSONDecoder().decode(GmailMessageResponse.self, from: data)
        guard let snippet = decoded.snippet, !snippet.isEmpty else {
            throw UsageProviderError.emptyData
        }
        return snippet
    }

    private func parseUsage(from snippet: String) -> ParsedUsage {
        let normalized = snippet.lowercased()

        let percentage = extractPercentage(from: snippet)
        let isExhausted = normalized.contains("100%") ||
            normalized.contains("exhausted") ||
            normalized.contains("limit reached") ||
            normalized.contains("quota reached")

        let isHighUsage = normalized.contains("80%") ||
            normalized.contains("high usage") ||
            normalized.contains("approaching") ||
            normalized.contains("nearly reached")

        return ParsedUsage(percentage: percentage, isHighUsage: isHighUsage, isExhausted: isExhausted)
    }

    private func extractPercentage(from text: String) -> Int? {
        let pattern = "(\\d{1,3})%"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let percentageRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return Int(text[percentageRange])
    }
}

private struct GmailListResponse: Codable {
    let messages: [GmailMessageSummary]?
}

private struct GmailMessageSummary: Codable {
    let id: String
}

private struct GmailMessageResponse: Codable {
    let id: String
    let snippet: String?
}

private struct ParsedUsage {
    let percentage: Int?
    let isHighUsage: Bool
    let isExhausted: Bool
}