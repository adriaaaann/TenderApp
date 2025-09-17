import SwiftData
import Foundation

@Model
class TenderData {
    var id: UUID
    var title: String
    var category: String
    var location: String
    var deadline: String
    var minimumBudget: String
    var maximumBudget: String
    var projectDescription: String
    var requirements: String
    var status: TenderStatus
    var dateCreated: Date
    var applicationsCount: Int
    
    init(
        title: String,
        category: String,
        location: String,
        deadline: String,
        minimumBudget: String,
        maximumBudget: String,
        projectDescription: String,
        requirements: String,
        status: TenderStatus = .active,
        applicationsCount: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.location = location
        self.deadline = deadline
        self.minimumBudget = minimumBudget
        self.maximumBudget = maximumBudget
        self.projectDescription = projectDescription
        self.requirements = requirements
        self.status = status
        self.dateCreated = Date()
        self.applicationsCount = applicationsCount
    }
}

enum TenderStatus: String, CaseIterable, Codable {
    case active = "Active"
    case closed = "Closed"
    case draft = "Draft"
    case pending = "Pending"
    
    var color: String {
        switch self {
        case .active:
            return "green"
        case .closed:
            return "red"
        case .draft:
            return "orange"
        case .pending:
            return "blue"
        }
    }
}


