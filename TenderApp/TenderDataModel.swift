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

extension TenderData {
    static let sampleData: [TenderData] = [
        TenderData(
            title: "Website Development",
            category: "Technology",
            location: "New York",
            deadline: "15/10/2025",
            minimumBudget: "5000",
            maximumBudget: "10000",
            projectDescription: "We need a modern, responsive website for our business",
            requirements: "Experience with React, Node.js, and modern web technologies",
            status: .active,
            applicationsCount: 12
        ),
        TenderData(
            title: "Office Renovation",
            category: "Construction",
            location: "San Francisco",
            deadline: "30/09/2025",
            minimumBudget: "15000",
            maximumBudget: "25000",
            projectDescription: "Complete renovation of our office space including interior design",
            requirements: "Licensed contractors with portfolio of commercial projects",
            status: .active,
            applicationsCount: 8
        ),
        TenderData(
            title: "Marketing Campaign",
            category: "Marketing",
            location: "Remote",
            deadline: "01/11/2025",
            minimumBudget: "3000",
            maximumBudget: "7000",
            projectDescription: "Digital marketing campaign for product launch",
            requirements: "Experience with social media marketing and content creation",
            status: .pending,
            applicationsCount: 5
        )
    ]
}
