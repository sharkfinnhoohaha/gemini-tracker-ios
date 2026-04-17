import Foundation
import StoreKit
import SwiftUI

/// Manages StoreKit 2 purchases.
/// Note: Since this is a standalone codebase not yet attached to App Store Connect
/// or a local StoreKit config file, this uses a robust mock layer that structurally 
/// mirrors StoreKit 2 capabilities.
@MainActor
public class StoreManager: ObservableObject {
    @Published public var isPowerUser: Bool = false
    @Published public var hasPriorityAlerts: Bool = false
    @Published public var isPurchasing: Bool = false
    
    public let products: [ProductMock] = [
        ProductMock(id: "com.overlook.geminitracker.lifetime", title: "Power User Pass", description: "Lifetime unlock for historical charts & widgets", price: "$9.99", type: .lifetime),
        ProductMock(id: "com.overlook.geminitracker.alerts", title: "Priority Alerts", description: "Push alerts for low prepay balance drops", price: "$12.00 / yr", type: .subscription)
    ]
    
    public init() {}
    
    public func purchase(product: ProductMock) async throws {
        isPurchasing = true
        defer { isPurchasing = false }
        
        // Simulate Apple's Payment Sheet delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        if product.type == .lifetime {
            self.isPowerUser = true
        } else if product.type == .subscription {
            self.hasPriorityAlerts = true
        }
    }
    
    public func restorePurchases() async throws {
        isPurchasing = true
        defer { isPurchasing = false }
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

public struct ProductMock: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let price: String
    public let type: ProductType
    
    public enum ProductType {
        case lifetime
        case subscription
    }
}
