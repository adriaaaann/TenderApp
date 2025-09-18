import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = ""
    @State private var companyName = ""
    @State private var showingRolePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationService.self) private var authService
    
    let roles = ["Organization", "Vendor"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Title Section
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Join Tender today")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 24) {
                            // Full Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField("Enter your full name", text: $fullName)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .font(.system(size: 16))
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField("Enter your email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .font(.system(size: 16))
                            }
                            
                            // Role Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Role")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    showingRolePicker = true
                                }) {
                                    HStack {
                                        Text(selectedRole.isEmpty ? "Select Role" : selectedRole)
                                            .foregroundColor(selectedRole.isEmpty ? .gray : .black)
                                            .font(.system(size: 16))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .actionSheet(isPresented: $showingRolePicker) {
                                    ActionSheet(
                                        title: Text("Select Role"),
                                        buttons: roles.map { role in
                                            .default(Text(role)) {
                                                selectedRole = role
                                            }
                                        } + [.cancel()]
                                    )
                                }
                            }
                            
                            // Company Name Field (only for Vendors)
                            if selectedRole == "Vendor" {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Company Name")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    TextField("Enter your company name", text: $companyName)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.system(size: 16))
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.3), value: selectedRole)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                SecureField("Enter your password", text: $password)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign Up Button
                        VStack(spacing: 16) {
                            Button(action: {
                                handleSignUp()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign Up")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isLoading ? Color.blue.opacity(0.7) : Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, 20)
                            
                            // Sign In Link
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                
                                Button("Sign In") {
                                    dismiss()
                                }
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Sign Up", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleSignUp() {
        isLoading = true
        
        // Convert selected role string to UserRole enum
        let userRole: UserRole
        switch selectedRole {
        case "Organization":
            userRole = .organization
        case "Vendor":
            userRole = .vendor
        default:
            alertMessage = "Please select a valid role"
            showAlert = true
            isLoading = false
            return
        }
        
        // Call authentication service
        let result = authService.signUp(
            fullName: fullName,
            email: email,
            password: password,
            role: userRole,
            companyName: selectedRole == "Vendor" ? companyName : nil
        )
        
        isLoading = false
        alertMessage = result.message
        showAlert = true
        
        // If successful, dismiss the view
        if result.isSuccess {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
}

#Preview {
    SignUpView()
        .environment(AuthenticationService())
}
