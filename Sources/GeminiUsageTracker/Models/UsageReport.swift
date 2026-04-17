import Foundation

public struct UsageReport: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let modelName: String
    
    // Core limit properties
    public let requestsUsed: Int
    public let requestsLimit: Int
    public let tokensUsed: Int
    public let tokensLimit: Int
    
    public var requestPercentage: Double {
        guard requestsLimit > 0 else { return 0 }
        return Double(requestsUsed) / Double(requestsLimit)
    }
    
    public var tokenPercentage: Double {
        guard tokensLimit > 0 else { return 0 }
        return Double(tokensUsed) / Double(tokensLimit)
    }
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), modelName: String, requestsUsed: Int, requestsLimit: Int, tokensUsed: Int, tokensLimit: Int) {
        self.id = id
        self.timestamp = timestamp
        self.modelName = modelName
        self.requestsUsed = requestsUsed
        self.requestsLimit = requestsLimit
        self.tokensUsed = tokensUsed
        self.tokensLimit = tokensLimit
    }
}

public struct HistoricalData: Codable, Identifiable {
    public let id: UUID
    public let date: Date
    public let tokensUsed: Int
    public let requestsUsed: Int
    
    public init(id: UUID = UUID(), date: Date, tokensUsed: Int, requestsUsed: Int) {
        self.id = id
        self.date = date
        self.tokensUsed = tokensUsed
        self.requestsUsed = requestsUsed
    }
}
