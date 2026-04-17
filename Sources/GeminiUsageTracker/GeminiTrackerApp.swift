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
        let projectId = ProcessInfo.processInfo.environment["GOOGLE_CLOUD_PROJECT_ID"]
        let usageService = UsageFactory.makeAPIService(
            authService: authService,
            projectId: projectId,
            preferredKind: nil
        )
        
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.dashboardViewModel = DashboardViewModel(apiService: usageService)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dashboardViewModel: dashboardViewModel)
                .environmentObject(authViewModel)
                .environmentObject(storeManager)
                .environmentObject(notificationManager)
                .onOpenURL { url in
                    _ = authViewModel.authService.handleOpenURL(url)
                }
        }
    }
}
