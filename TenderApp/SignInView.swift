import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedUserType: UserType = .vendor
    @State private var showingOrganizationDashboard = false
    @State private var showingVendorDashboard = false
    @Environment(\.presentationMode) var presentationMode
    
    enum UserType: String, CaseIterable {
        case vendor = "Vendor"
        case organization = "Organization"
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        ModernSignInHeader()
                            .padding(.top, AppSpacing.lg)
                        
                        ModernUserTypeSelector(selectedType: $selectedUserType)
                        
                        ModernSignInForm(email: $email, password: $password)
                        
                        AnimatedButton(title: "Sign In", icon: "arrow.right", style: .primary) {
                            handleSignIn()
                        }
                        .padding(.top, AppSpacing.md)
                        
                        ModernAlternativeSignInOptions()
                        
                        Spacer(minLength: AppSpacing.xl)
                        
                        ModernSignUpPrompt()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .frame(minHeight: geometry.size.height)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.background,
                            AppColors.primaryLight.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                }
            }
        }
        .fullScreenCover(isPresented: $showingOrganizationDashboard) {
            OrganizationDashboardView()
        }
        .fullScreenCover(isPresented: $showingVendorDashboard) {
            VendorDashboardView()
        }
    }
    
    private func handleSignIn() {
        if selectedUserType == .organization {
            showingOrganizationDashboard = true
        } else if selectedUserType == .vendor {
            showingVendorDashboard = true
        }
    }
}

struct ModernSignInHeader: View {
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Welcome Back")
                .font(AppFonts.displayMedium)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: animateTitle ? 0 : -20)
                .opacity(animateTitle ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0), value: animateTitle)
            
            Text("Sign in to your account")
                .font(AppFonts.bodyLarge)
                .foregroundColor(AppColors.secondaryText)
                .offset(x: animateSubtitle ? 0 : -15)
                .opacity(animateSubtitle ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.2), value: animateSubtitle)
        }
        .onAppear {
            animateTitle = true
            animateSubtitle = true
        }
    }
}

struct ModernUserTypeSelector: View {
    @Binding var selectedType: SignInView.UserType
    @State private var animateSelector = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("I'm signing in as:")
                .font(AppFonts.headingSmall)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.md) {
                ForEach(SignInView.UserType.allCases, id: \.self) { type in
                    ModernUserTypeButton(
                        title: type.rawValue,
                        isSelected: selectedType == type
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                            selectedType = type
                        }
                    }
                }
                Spacer()
            }
            .offset(y: animateSelector ? 0 : 10)
            .opacity(animateSelector ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.4), value: animateSelector)
        }
        .onAppear {
            animateSelector = true
        }
    }
}

struct ModernUserTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.buttonMedium)
                .foregroundColor(isSelected ? .white : AppColors.primary)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .frame(minWidth: 120)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                        .fill(
                            isSelected 
                            ? LinearGradient(
                                gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                        .stroke(
                            isSelected ? Color.clear : AppColors.border,
                            lineWidth: isSelected ? 0 : 1.5
                        )
                )
                .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernSignInForm: View {
    @Binding var email: String
    @Binding var password: String
    @State private var animateForm = false
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ModernTextField(
                title: "Email",
                placeholder: "Enter your email",
                icon: "envelope",
                text: $email
            )
            
            ModernTextField(
                title: "Password",
                placeholder: "Enter your password",
                icon: "lock",
                text: $password,
                isSecure: true
            )
        }
        .offset(y: animateForm ? 0 : 20)
        .opacity(animateForm ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.6), value: animateForm)
        .onAppear {
            animateForm = true
        }
    }
}

struct ModernAlternativeSignInOptions: View {
    @State private var animateOptions = false
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack {
                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: 1)
                
                Text("or")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal, AppSpacing.md)
                
                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: 1)
            }
            
            AnimatedButton(
                title: "Sign in with Face ID",
                icon: "faceid",
                style: .secondary
            ) {
                print("Sign in with Face ID")
            }
            
            Button("Forgot your password?") {
                print("Forgot password")
            }
            .font(AppFonts.buttonMedium)
            .foregroundColor(AppColors.primary)
        }
        .offset(y: animateOptions ? 0 : 15)
        .opacity(animateOptions ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.8), value: animateOptions)
        .onAppear {
            animateOptions = true
        }
    }
}

struct ModernSignUpPrompt: View {
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: AppSpacing.xs) {
                Text("Don't have an account?")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.secondaryText)
                
                Button("Sign Up") {
                    print("Navigate to Sign Up")
                }
                .font(AppFonts.buttonMedium)
                .foregroundColor(AppColors.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SignInView()
}
