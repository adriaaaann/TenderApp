import SwiftData
import Foundation

@Model
class User {
    @Attribute(.unique) var email: String
    var fullName: String
    var password: String // In production, this should be hashed
    var role: UserRole
    var companyName: String?
    var createdAt: Date
    
    init(email: String, fullName: String, password: String, role: UserRole, companyName: String? = nil) {
        self.email = email
        self.fullName = fullName
        self.password = password
        self.role = role
        self.companyName = companyName
        self.createdAt = Date()
    }
}

enum UserRole: String, Codable, CaseIterable {
    case vendor = "Vendor"
    case organization = "Organization"
}
