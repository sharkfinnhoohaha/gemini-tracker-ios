import Foundation
import Combine

@MainActor
public class AuthViewModel: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var error: String? = nil
    
    public let authService: GoogleAuthService
    private var cancellables = Set<AnyCancellable>()
    
    public init(authService: GoogleAuthService) {
        self.authService = authService
        self.isAuthenticated = authService.isAuthenticated
        
        authService.$isAuthenticated
            .receive(on: RunLoop.main)
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
    }
    
    public func signIn() {
        isLoading = true
        error = nil
        
        Task {
            do {
                try await authService.signIn()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    public func signOut() {
        authService.signOut()
    }
}
