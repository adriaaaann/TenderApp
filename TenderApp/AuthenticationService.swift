import SwiftData
import SwiftUI

@Observable
class AuthenticationService {
    var currentUser: User?
    var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    private var modelContext: ModelContext?
    
    init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // Sign Up Function
    func signUp(fullName: String, email: String, password: String, role: UserRole, companyName: String?) -> AuthResult {
        guard let context = modelContext else {
            return .failure("Database not available")
        }
        
        // Validate input
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            return .failure("Please fill in all required fields")
        }
        
        guard isValidEmail(email) else {
            return .failure("Please enter a valid email address")
        }
        
        guard password.count >= 6 else {
            return .failure("Password must be at least 6 characters long")
        }
        
        // For vendors, company name is required
        if role == .vendor && (companyName?.isEmpty ?? true) {
            return .failure("Company name is required for vendors")
        }
        
        // Check if user already exists
        let lowercaseEmail = email.lowercased()
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == lowercaseEmail
            }
        )
        
        do {
            let existingUsers = try context.fetch(descriptor)
            if !existingUsers.isEmpty {
                return .failure("An account with this email already exists")
            }
            
            // Create new user
            let newUser = User(
                email: email.lowercased(),
                fullName: fullName,
                password: password, // In production, hash this password
                role: role,
                companyName: companyName
            )
            
            context.insert(newUser)
            try context.save()
            
            // Do not set as current user - require explicit sign in
            // self.currentUser = newUser
            
            return .success("Account created successfully! Please sign in to continue.")
            
        } catch {
            return .failure("Failed to create account: \(error.localizedDescription)")
        }
    }
    
    // Sign In Function
    func signIn(email: String, password: String, role: UserRole) -> AuthResult {
        guard let context = modelContext else {
            return .failure("Database not available")
        }
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            return .failure("Please enter email and password")
        }
        
        // Find user with matching email first
        let lowercaseEmail = email.lowercased()
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == lowercaseEmail
            }
        )
        
        do {
            let users = try context.fetch(descriptor)
            
            // Filter by role in Swift since SwiftData predicates can be tricky with enums
            let matchingUsers = users.filter { $0.role == role }
            
            guard let user = matchingUsers.first else {
                return .failure("No account found with this email and role")
            }
            
            // Check password (in production, compare hashed passwords)
            guard user.password == password else {
                return .failure("Incorrect password")
            }
            
            // Set as current user
            self.currentUser = user
            
            return .success("Signed in successfully")
            
        } catch {
            return .failure("Failed to sign in: \(error.localizedDescription)")
        }
    }
    
    // Sign Out Function
    func signOut() {
        self.currentUser = nil
    }
    
    // Helper function to validate email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

enum AuthResult {
    case success(String)
    case failure(String)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var message: String {
        switch self {
        case .success(let message):
            return message
        case .failure(let error):
            return error
        }
    }
}
