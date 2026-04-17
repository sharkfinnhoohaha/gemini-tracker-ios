import SwiftUI

public struct UsageProgressBar: View {
    public let title: String
    public let used: Int
    public let limit: Int
    public let percentage: Double
    public let formatTokens: Bool
    
    @State private var animatedPercentage: Double = 0
    
    public init(title: String, used: Int, limit: Int, percentage: Double, formatTokens: Bool = false) {
        self.title = title
        self.used = used
        self.limit = limit
        self.percentage = percentage
        self.formatTokens = formatTokens
    }
    
    private var progressColor: Color {
        if percentage < 0.6 { return .green }
        if percentage < 0.85 { return .orange }
        return .red
    }
    
    private func formatNumber(_ number: Int) -> String {
        if !formatTokens { return "\(number)" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        if number >= 1_000_000 {
            return "\(formatter.string(from: NSNumber(value: Double(number) / 1_000_000.0)) ?? "")M"
        } else if number >= 1_000 {
            return "\(formatter.string(from: NSNumber(value: Double(number) / 1_000.0)) ?? "")K"
        }
        return "\(number)"
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(animatedPercentage * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background Track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 16)
                    
                    // Animated Progress Fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [progressColor.opacity(0.7), progressColor]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * CGFloat(animatedPercentage)), height: 16)
                        .shadow(color: progressColor.opacity(0.4), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 16)
            
            HStack {
                Text("\(formatNumber(used)) used")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(formatNumber(limit)) limit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SystemBackgroundColor.opacity(0.5)) // cross-platform fallback
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7, blendDuration: 0.1)) {
                animatedPercentage = percentage
            }
        }
    }
}
