import Foundation
import GoogleSignIn
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class GoogleAuthService: ObservableObject {
    public static let defaultClientID = "1096942919584-r3t36c8ambmif6u8h9f3loumtlm06vjs.apps.googleusercontent.com"
    public static let reversedClientID = "com.googleusercontent.apps.1096942919584-r3t36c8ambmif6u8h9f3loumtlm06vjs"

    @Published public var isAuthenticated: Bool = false
    @Published public var userName: String? = nil
    @Published public var userEmail: String? = nil
    private var accessToken: String? = nil

    // Keep these aligned with Google Cloud Console OAuth consent scopes.
    public let requiredScopes: [String] = [
        "https://www.googleapis.com/auth/gmail.readonly",
        "https://www.googleapis.com/auth/cloud-billing.readonly"
    ]

    private let clientID: String

    public init(clientID: String? = nil) {
        let bundleClientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String
        self.clientID = clientID ?? bundleClientID ?? Self.defaultClientID
    }
    
    @MainActor
    public func signIn() async throws {
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration

        #if os(macOS)
        guard let presentingWindow = Self.resolvePresentingWindow() else {
            throw UsageProviderError.apiError("Unable to find a macOS window for Google Sign-In.")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingWindow,
            hint: nil,
            additionalScopes: requiredScopes
        )
        #else
        guard let presentingViewController = Self.resolveRootViewController() else {
            throw UsageProviderError.apiError("Unable to find a presenting view controller for Google Sign-In.")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: requiredScopes
        )
        #endif

        let user = result.user
        let profile = user.profile

        self.isAuthenticated = true
        self.userName = profile?.name
        self.userEmail = profile?.email
        self.accessToken = user.accessToken.tokenString
    }
    
    @MainActor
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.isAuthenticated = false
        self.userName = nil
        self.userEmail = nil
        self.accessToken = nil
    }

    @MainActor
    public func getBearerToken() async throws -> String {
        guard isAuthenticated, let accessToken else {
            throw UsageProviderError.unauthorized
        }
        return accessToken
    }

    @MainActor
    @discardableResult
    public func handleOpenURL(_ url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    #if os(macOS)
    @MainActor
    private static func resolvePresentingWindow() -> NSWindow? {
        let application = NSApplication.shared
        return application.keyWindow
            ?? application.mainWindow
            ?? application.windows.first(where: { $0.isVisible })
            ?? application.windows.first
    }
    #else
    @MainActor
    private static func resolveRootViewController() -> UIViewController? {
        let activeScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        let keyWindow = activeScenes
            .flatMap(\.windows)
            .first { $0.isKeyWindow }

        return keyWindow?.rootViewController
    }
    #endif
}
