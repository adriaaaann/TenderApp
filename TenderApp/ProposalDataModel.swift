import SwiftData
import Foundation

@Model
class ProposalData {
    var id: UUID
    var tenderId: UUID
    var vendorEmail: String
    var vendorName: String
    var companyName: String
    var contactPerson: String
    var email: String
    var phone: String
    var proposalTitle: String = ""
    var proposedBudget: String
    var timeline: String
    var proposalDescription: String
    var experience: String
    var attachments: [String]
    var status: ProposalStatus
    var dateSubmitted: Date
    
    init(
        tenderId: UUID,
        vendorEmail: String,
        vendorName: String,
        companyName: String,
        contactPerson: String,
        email: String,
        phone: String,
        proposalTitle: String,
        proposedBudget: String,
        timeline: String,
        proposalDescription: String,
        experience: String,
        attachments: [String] = []
    ) {
        self.id = UUID()
        self.tenderId = tenderId
        self.vendorEmail = vendorEmail
        self.vendorName = vendorName
        self.companyName = companyName
        self.contactPerson = contactPerson
        self.email = email
        self.phone = phone
        self.proposalTitle = proposalTitle
        self.proposedBudget = proposedBudget
        self.timeline = timeline
        self.proposalDescription = proposalDescription
        self.experience = experience
        self.attachments = attachments
        self.status = .submitted
        self.dateSubmitted = Date()
    }
}

enum ProposalStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case submitted = "Submitted"
    case underReview = "Under Review"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case withdrawn = "Withdrawn"
    
    var color: String {
        switch self {
        case .pending:
            return "gray"
        case .submitted:
            return "blue"
        case .underReview:
            return "orange"
        case .accepted:
            return "green"
        case .rejected:
            return "red"
        case .withdrawn:
            return "gray"
        }
    }
}
