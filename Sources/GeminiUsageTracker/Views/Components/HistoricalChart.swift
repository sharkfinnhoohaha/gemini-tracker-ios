import SwiftUI
import Charts

public struct HistoricalChart: View {
    public let data: [HistoricalData]
    
    public init(data: [HistoricalData]) {
        self.data = data
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage History (7 Days)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart {
                ForEach(data) { item in
                    AreaMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Tokens", item.tokensUsed)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Tokens", item.tokensUsed)
                    )
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(Circle())
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 200)
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(SystemBackgroundColor.opacity(0.5))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}
