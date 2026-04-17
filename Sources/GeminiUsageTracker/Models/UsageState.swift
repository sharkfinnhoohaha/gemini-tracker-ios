import Foundation

public enum UsageStatus: String, Codable {
    case normal
    case highUsage
    case exhausted
}

public enum UsageSource: String, Codable {
    case googleCloud
    case gmail
    case mock
}

public struct UsageState: Codable {
    public let source: UsageSource
    public let status: UsageStatus
    public let usagePercentage: Double?
    public let summary: String
    public let metadata: [String: String]
    public let timestamp: Date

    public init(
        source: UsageSource,
        status: UsageStatus,
        usagePercentage: Double? = nil,
        summary: String,
        metadata: [String: String] = [:],
        timestamp: Date = Date()
    ) {
        self.source = source
        self.status = status
        self.usagePercentage = usagePercentage
        self.summary = summary
        self.metadata = metadata
        self.timestamp = timestamp
    }
}