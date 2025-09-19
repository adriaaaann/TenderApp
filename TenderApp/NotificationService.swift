import UserNotifications
import SwiftData

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    init() {}
    
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
    
    func notifyVendorOfProposalStatusChange(proposal: ProposalData, tender: TenderData, modelContext: ModelContext) {
        let vendorEmail = proposal.vendorEmail
        let descriptor = FetchDescriptor<User>(predicate: #Predicate<User> { user in
            user.email == vendorEmail
        })
        
        do {
            let users = try modelContext.fetch(descriptor)
            
            let vendors = users.filter { $0.role == .vendor }
            guard let vendor = vendors.first else {
                print("Vendor not found for proposal notification: \(proposal.vendorEmail)")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Proposal Status Updated"
            
            let diplomaticMessage = createDiplomaticMessage(
                status: proposal.status,
                tenderTitle: tender.title,
                vendorName: vendor.fullName
            )
            
            content.body = diplomaticMessage
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            content.userInfo = [
                "proposalId": proposal.id.uuidString,
                "tenderId": tender.id.uuidString,
                "tenderTitle": tender.title,
                "status": proposal.status.rawValue,
                "vendorEmail": proposal.vendorEmail,
                "action": "proposal_status_updated"
            ]
            
            let identifier = "proposal-status-\(proposal.id.uuidString)-\(proposal.status.rawValue.lowercased())"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling proposal status notification for vendor \(vendor.email): \(error)")
                } else {
                    print("Proposal status notification sent to vendor: \(vendor.email) - Status: \(proposal.status.rawValue)")
                }
            }
            
        } catch {
            print("Error fetching vendor for proposal status notification: \(error)")
        }
    }
    
    private func createDiplomaticMessage(status: ProposalStatus, tenderTitle: String, vendorName: String) -> String {
        switch status {
        case .pending:
            return "Thank you for your proposal submission for '\(tenderTitle)'. We are currently reviewing your application and will update you on our decision."
            
        case .accepted:
            return "We are pleased to inform you that your proposal for '\(tenderTitle)' has been accepted. We look forward to working with you on this project."
            
        case .rejected:
            return "Thank you for your interest in '\(tenderTitle)'. After careful consideration, we have decided to proceed with another vendor for this project. We appreciate your time and effort in preparing your proposal."
        }
    }
}
