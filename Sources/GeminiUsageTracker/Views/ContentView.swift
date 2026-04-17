import SwiftUI

public struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    private let dashboardViewModel: DashboardViewModel
    
    public init(dashboardViewModel: DashboardViewModel) {
        self.dashboardViewModel = dashboardViewModel
    }
    
    public var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                DashboardView(viewModel: dashboardViewModel)
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }
}
