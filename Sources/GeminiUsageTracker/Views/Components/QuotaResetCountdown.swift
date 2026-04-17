import SwiftUI

/// Live countdown to the next Gemini free-tier quota reset.
/// Gemini's free-tier daily quotas reset at 00:00 Pacific Time.
public struct QuotaResetCountdown: View {
    @State private var now: Date = Date()

    private let ticker = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        Text("Limits reset in \(Self.formatRemaining(from: now))")
            .onReceive(ticker) { value in
                now = value
            }
    }

    static func formatRemaining(from date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        if let pacific = TimeZone(identifier: "America/Los_Angeles") {
            calendar.timeZone = pacific
        }

        guard let nextMidnight = calendar.nextDate(
            after: date,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return "soon"
        }

        let remaining = nextMidnight.timeIntervalSince(date)
        let totalMinutes = max(0, Int(remaining / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
