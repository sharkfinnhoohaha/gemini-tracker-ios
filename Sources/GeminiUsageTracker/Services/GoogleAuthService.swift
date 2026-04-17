import Foundation

public class GoogleAuthService: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var userName: String? = nil
    @Published public var userEmail: String? = nil
    
    public init() {}
    
    // In a real implementation, we would use:
    // import GoogleSignIn
    // GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
    
    public func signIn() async throws {
        // Simulate auth delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.userName = "Finn Bennett"
            self.userEmail = "finn@example.com"
        }
    }
    
    public func signOut() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.userName = nil
            self.userEmail = nil
        }
    }
}
