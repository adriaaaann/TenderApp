import UserNotifications
import SwiftData

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Notification permission error: \(error)")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }
    
    func notifyVendorsOfNewTender(tender: TenderData, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<User>()
        
        do {
            let allUsers = try modelContext.fetch(descriptor)
            let vendors = allUsers.filter { $0.role == .vendor }
            
            if vendors.isEmpty {
                print("No vendor users found - notifications not sent")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "New Tender Available"
            content.body = "A new tender '\(tender.title)' has been published in \(tender.category)"
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            content.userInfo = [
                "tenderId": tender.id.uuidString,
                "tenderTitle": tender.title,
                "category": tender.category
            ]
            
            for vendor in vendors {
                let identifier = "tender-\(tender.id.uuidString)-vendor-\(vendor.email)"
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification for vendor \(vendor.email): \(error)")
                    } else {
                        print("Notification scheduled for vendor: \(vendor.email)")
                    }
                }
            }
            
            print("Notifications sent to \(vendors.count) vendors for tender: \(tender.title)")
            
        } catch {
            print("Error fetching vendors for notifications: \(error)")
        }
    }
    
    func notifyVendorsOfTenderUpdate(tender: TenderData, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<User>()
        
        do {
            let allUsers = try modelContext.fetch(descriptor)
            let vendors = allUsers.filter { $0.role == .vendor }
            
            if vendors.isEmpty {
                print("No vendor users found - update notifications not sent")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Tender Updated"
            content.body = "The tender '\(tender.title)' has been updated. Check the latest details!"
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            content.userInfo = [
                "tenderId": tender.id.uuidString,
                "tenderTitle": tender.title,
                "category": tender.category,
                "action": "updated"
            ]
            
            for vendor in vendors {
                let identifier = "tender-update-\(tender.id.uuidString)-vendor-\(vendor.email)"
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling update notification for vendor \(vendor.email): \(error)")
                    } else {
                        print("Update notification scheduled for vendor: \(vendor.email)")
                    }
                }
            }
            
            print("Update notifications sent to \(vendors.count) vendors for tender: \(tender.title)")
            
        } catch {
            print("Error fetching vendors for update notifications: \(error)")
        }
    }
    
    func handleNotificationReceived(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if let tenderId = userInfo["tenderId"] as? String,
           let tenderTitle = userInfo["tenderTitle"] as? String {
            print("Received notification for tender: \(tenderTitle) (ID: \(tenderId))")
        }
    }
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
