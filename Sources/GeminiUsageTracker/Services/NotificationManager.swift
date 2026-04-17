import Foundation
import UserNotifications

@MainActor
public class NotificationManager: ObservableObject {
    @Published public var isAuthorized: Bool = false
    
    public init() {}
    
    public func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        self.isAuthorized = granted
        return granted
    }
    
    public func schedulePrepayAlert() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Low Prepay Balance"
        content.body = "Your Gemini API prepay balance has dropped below $10.00."
        
        // Apple-style premium touch: Custom high-fidelity sound
        // Ensure "OverlookAlert.caf" is added to the Xcode project bundle
        content.sound = UNNotificationSound(named: UNNotificationSoundName("OverlookAlert.caf"))
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
