import SwiftUI

public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var notificationManager: NotificationManager
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        Text("Unlock Gemini Tracker")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("Get detailed historical charts, widgets, and real-time prepay alerts.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Products
                    VStack(spacing: 16) {
                        ForEach(storeManager.products) { product in
                            ProductRow(product: product)
                                .environmentObject(storeManager)
                                .environmentObject(notificationManager)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Restore
                    Button("Restore Purchases") {
                        Task { try? await storeManager.restorePurchases() }
                    }
                    .font(.footnote.bold())
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
            .background(SystemBackgroundColor.ignoresSafeArea())
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
    }
}

struct ProductRow: View {
    let product: ProductMock
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var error: String?
    
    var isPurchased: Bool {
        if product.type == .lifetime { return storeManager.isPowerUser }
        if product.type == .subscription { return storeManager.hasPriorityAlerts }
        return false
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                
                if isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Button(action: purchase) {
                        Text(product.price)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                    .disabled(storeManager.isPurchasing)
                }
            }
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SystemBackgroundColor.opacity(0.5))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPurchased ? Color.green.opacity(0.3) : Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func purchase() {
        Task {
            do {
                if product.type == .subscription {
                    // Request notification permission before buying the alert tier
                    let granted = try await notificationManager.requestAuthorization()
                    if !granted {
                        error = "Notifications must be enabled to receive Prepay Alerts."
                        return
                    }
                }
                
                try await storeManager.purchase(product: product)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
