import SwiftUI

public struct DashboardView: View {
    @ObservedObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var storeManager: StoreManager
    @State private var showPaywall = false
    
    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gemini API Tracker")
                            .font(.largeTitle.bold())
                        Text("Welcome back, \(authViewModel.authService.userName ?? "User")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    if let usageState = viewModel.usageState {
                        ProviderStatusBadge(usageState: usageState)
                    }
                    
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Circle().fill(SystemBackgroundColor.opacity(0.8)))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                if viewModel.isLoading && viewModel.currentUsage == nil {
                    ProgressView()
                        .padding(.top, 50)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if let usage = viewModel.currentUsage {
                    // Usage Stats
                    VStack(spacing: 20) {
                        UsageProgressBar(
                            title: "Token Usage (\(usage.modelName))",
                            used: usage.tokensUsed,
                            limit: usage.tokensLimit,
                            percentage: usage.tokenPercentage,
                            formatTokens: true
                        )
                        
                        UsageProgressBar(
                            title: "Requests Per Minute",
                            used: usage.requestsUsed,
                            limit: usage.requestsLimit,
                            percentage: usage.requestPercentage
                        )
                    }
                    .padding(.horizontal)
                    
                    // Premium Features
                    VStack(spacing: 20) {
                        if storeManager.isPowerUser {
                            // Projection Box
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Projected End of Month")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(viewModel.projectedEndOfMonthTokens) tokens")
                                        .font(.title2.bold())
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue.opacity(0.5))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .padding(.horizontal)
                            
                            // Historical Chart
                            if !viewModel.historicalData.isEmpty {
                                HistoricalChart(data: viewModel.historicalData)
                                    .padding(.horizontal)
                            }
                        } else {
                            // Free Tier Lock
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("Historical charts & projections are locked.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button("Unlock Power User Pass") {
                                    showPaywall = true
                                }
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(SystemBackgroundColor.opacity(0.5))
                            )
                            .padding(.horizontal)
                            
                            // Free tier countdown
                            Text("Limits reset in 4 hours 12 mins")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [SystemBackgroundColor, Color.blue.opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            viewModel.fetchData()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
