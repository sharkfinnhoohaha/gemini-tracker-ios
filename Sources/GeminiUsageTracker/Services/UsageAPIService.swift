import Foundation

public protocol UsageAPIService {
    func fetchCurrentUsage() async throws -> UsageReport
    func fetchHistoricalUsage(days: Int) async throws -> [HistoricalData]
}

public class MockUsageProvider: UsageAPIService {
    public init() {}
    
    public func fetchCurrentUsage() async throws -> UsageReport {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return UsageReport(
            modelName: "Gemini 1.5 Pro",
            requestsUsed: 420,
            requestsLimit: 500,
            tokensUsed: 1_250_000,
            tokensLimit: 2_000_000
        )
    }
    
    public func fetchHistoricalUsage(days: Int) async throws -> [HistoricalData] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        var history: [HistoricalData] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in (0..<days).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // Generate somewhat realistic looking curve
                let baseTokens = 50000
                let randomNoise = Int.random(in: -10000...20000)
                let trend = i < 3 ? 40000 : 0 // higher usage recently
                
                history.append(HistoricalData(
                    date: date,
                    tokensUsed: max(0, baseTokens + randomNoise + trend),
                    requestsUsed: Int.random(in: 10...100)
                ))
            }
        }
        return history
    }
}
