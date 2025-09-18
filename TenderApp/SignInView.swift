import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedUserType: UserType = .vendor
    @State private var showingOrganizationDashboard = false
    @State private var showingVendorDashboard = false
    @State private var showingSignUp = false
    @State private var showingRolePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationService.self) private var authService
    
    enum UserType: String, CaseIterable {
        case vendor = "Vendor"
        case organization = "Organization"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
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
                
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Sign in to your account")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        
                        VStack(spacing: 24) {
                        
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Role")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    showingRolePicker = true
                                }) {
                                    HStack {
                                        Text(selectedUserType.rawValue)
                                            .foregroundColor(.black)
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
                                        buttons: UserType.allCases.map { type in
                                            .default(Text(type.rawValue)) {
                                                selectedUserType = type
                                            }
                                        } + [.cancel()]
                                    )
                                }
                            }
                            
                            
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
                        
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                handleSignIn()
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
                            
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                    
                                    Text("or")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 16)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                }
                                .padding(.horizontal, 20)
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "faceid")
                                            .font(.system(size: 16))
                                        Text("Sign in with Face ID")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal, 20)
                                
                                Button("Forgot your password?") {
                                    
                                }
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                            }
                            
                            
                            HStack {
                                Text("dont have an account ? ")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                
                                Button("Sign up") {
                                    showingSignUp = true
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
        .fullScreenCover(isPresented: $showingOrganizationDashboard) {
            OrganizationDashboardView()
        }
        .fullScreenCover(isPresented: $showingVendorDashboard) {
            VendorDashboardView()
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .alert("Sign In", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleSignIn() {
        isLoading = true
        
        
        let userRole: UserRole = selectedUserType == .organization ? .organization : .vendor
        
        
        let result = authService.signIn(email: email, password: password, role: userRole)
        
        isLoading = false
        
        if result.isSuccess {
         
            if selectedUserType == .organization {
                showingOrganizationDashboard = true
            } else {
                showingVendorDashboard = true
            }
        } else {
            alertMessage = result.message
            showAlert = true
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationService())
}
