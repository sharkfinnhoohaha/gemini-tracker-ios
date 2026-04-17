import Foundation
import SwiftUI

@MainActor
public class DashboardViewModel: ObservableObject {
    @Published public var currentUsage: UsageReport?
    @Published public var historicalData: [HistoricalData] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let apiService: UsageAPIService
    
    public init(apiService: UsageAPIService) {
        self.apiService = apiService
    }
    
    public func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch concurrently
                async let usageTask = apiService.fetchCurrentUsage()
                async let historyTask = apiService.fetchHistoricalUsage(days: 7)
                
                let (usage, history) = try await (usageTask, historyTask)
                
                self.currentUsage = usage
                self.historicalData = history
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to load usage data. Please try again."
                self.isLoading = false
            }
        }
    }
    
    public var projectedEndOfMonthTokens: Int {
        guard let usage = currentUsage else { return 0 }
        
        // Simple projection: assume linear usage
        let calendar = Calendar.current
        let today = Date()
        guard let range = calendar.range(of: .day, in: .month, for: today),
              let day = calendar.dateComponents([.day], from: today).day else {
            return usage.tokensUsed
        }
        
        let daysInMonth = range.count
        let dailyAverage = Double(usage.tokensUsed) / Double(day)
        return Int(dailyAverage * Double(daysInMonth))
    }
}
