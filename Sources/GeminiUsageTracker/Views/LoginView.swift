import SwiftUI

public struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Logo / Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("Gemini Tracker")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Monitor your API usage and rate limits securely.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            if authViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else {
                Button(action: {
                    authViewModel.signIn()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
            }
            
            if let error = authViewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .background(SystemBackgroundColor.ignoresSafeArea())
    }
}
