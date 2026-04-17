import SwiftUI

public struct ProviderStatusBadge: View {
    private let usageState: UsageState
    @State private var showSourceInfo = false

    public init(usageState: UsageState) {
        self.usageState = usageState
    }

    public var body: some View {
        Button {
            showSourceInfo = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption.bold())
                Text(labelText)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.10))
            )
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .alert("Data Source", isPresented: $showSourceInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(explanationText)
        }
        .accessibilityLabel("Provider status")
        .accessibilityValue(labelText)
    }

    private var iconName: String {
        switch usageState.source {
        case .googleCloud:
            return "cloud.fill"
        case .gmail:
            return "envelope.fill"
        case .mock:
            return "testtube.2"
        }
    }

    private var labelText: String {
        switch usageState.source {
        case .googleCloud:
            return "Live API"
        case .gmail:
            return "Email Sync"
        case .mock:
            return "Simulated"
        }
    }

    private var explanationText: String {
        switch usageState.source {
        case .googleCloud:
            return "Usage is estimated from your Google Cloud Billing project status and metadata."
        case .gmail:
            return "Usage estimated from your latest Google One notifications from the last 30 days."
        case .mock:
            return "Usage values are simulated for development and testing."
        }
    }
}
