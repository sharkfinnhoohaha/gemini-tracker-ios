import SwiftUI

@main
struct GeminiTrackerApp: App {
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var storeManager = StoreManager()
    @StateObject private var notificationManager = NotificationManager()
    private let dashboardViewModel: DashboardViewModel
    
    init() {
        // App Dependency Injection
        let authService = GoogleAuthService()
        let usageService = MockUsageProvider()
        
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.dashboardViewModel = DashboardViewModel(apiService: usageService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dashboardViewModel: dashboardViewModel)
                .environmentObject(authViewModel)
                .environmentObject(storeManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(.dark) // Force dark mode for premium look
        }
    }
}
