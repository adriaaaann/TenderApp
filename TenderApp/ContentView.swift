import SwiftUI

struct AppColors {
    static let primary = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let accent = Color(red: 0.25, green: 0.45, blue: 0.95)
    static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let warning = Color(red: 0.95, green: 0.65, blue: 0.2)
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
    
    static let primaryText = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let secondaryText = Color(red: 0.4, green: 0.4, blue: 0.4)
    static let tertiaryText = Color(red: 0.6, green: 0.6, blue: 0.6)
    static let inverseText = Color.white
    
    static let background = Color(red: 0.98, green: 0.99, blue: 1.0)
    static let surfaceBackground = Color.white
    static let subtleBackground = Color(red: 0.95, green: 0.97, blue: 1.0)
    
    static let separator = Color(red: 0.9, green: 0.9, blue: 0.9)
    static let hover = Color(red: 0.95, green: 0.95, blue: 0.95)
    
    static let primaryDark = primary
    static let primaryLight = subtleBackground
    static let cardBackground = surfaceBackground
    static let inputBackground = subtleBackground
    static let shadow = Color.black.opacity(0.03)
    static let border = separator
}

struct AppFonts {
    
    static let displayLarge = Font.system(size: 40, weight: .light)
    static let displayMedium = Font.system(size: 32, weight: .regular)
    static let titleLarge = Font.system(size: 28, weight: .medium)
    static let titleMedium = Font.system(size: 24, weight: .medium)
    static let titleSmall = Font.system(size: 20, weight: .semibold)
    
    static let headingLarge = Font.system(size: 18, weight: .semibold)
    static let headingMedium = Font.system(size: 16, weight: .medium)
    static let headingSmall = Font.system(size: 14, weight: .medium)
    
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    
    static let labelLarge = Font.system(size: 15, weight: .semibold)
    static let labelMedium = Font.system(size: 13, weight: .semibold)
    static let labelSmall = Font.system(size: 11, weight: .medium)
    
    static let caption = Font.system(size: 12, weight: .regular)
    static let overline = Font.system(size: 10, weight: .semibold)
    
    
    static let headingMedium_old = headingLarge
    static let headingSmall_old = headingMedium
    static let buttonLarge = labelLarge
    static let buttonMedium = labelMedium
    static let buttonSmall = labelSmall
    static let captionMedium = Font.system(size: 12, weight: .medium)
}

struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
}

struct AppShadows {
    static let small = Shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
    static let large = Shadow(color: AppColors.shadow, radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct ModernCard: View {
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.large)
            .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
    }
}

struct GradientIcon: View {
    let iconName: String
    let size: CGFloat
    let gradientColors: [Color]
    
    init(iconName: String, size: CGFloat = 60, gradientColors: [Color] = [AppColors.primary, AppColors.primaryDark]) {
        self.iconName = iconName
        self.size = size
        self.gradientColors = gradientColors
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size + 40, height: size + 40)
            
            Image(systemName: iconName)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(.white)
        }
        .shadow(color: AppColors.primary.opacity(0.3), radius: 12, x: 0, y: 8)
    }
}

struct AnimatedButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary, secondary, ghost
    }
    
    init(title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AppFonts.buttonMedium)
                }
                
                Text(title)
                    .font(AppFonts.buttonLarge)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .cornerRadius(AppCornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private var backgroundColor: some View {
        switch style {
        case .primary:
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .secondary:
            return AnyView(AppColors.primaryLight)
        case .ghost:
            return AnyView(Color.clear)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .ghost:
            return AppColors.primary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .secondary:
            return Color.clear
        case .ghost:
            return AppColors.border
        }
    }
    
    private var borderWidth: CGFloat {
        style == .ghost ? 1.5 : 0
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return AppColors.primary.opacity(0.3)
        case .secondary, .ghost:
            return AppColors.shadow
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return 12
        case .secondary, .ghost:
            return 4
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case .primary:
            return 6
        case .secondary, .ghost:
            return 2
        }
    }
}

struct ModernTextField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    let isSecure: Bool
    
    @State private var isFocused = false
    
    init(title: String, placeholder: String, icon: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isFocused ? AppColors.primary : AppColors.tertiaryText)
                    .frame(width: 24)
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text, onEditingChanged: { editing in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isFocused = editing
                            }
                        })
                    }
                }
                .font(AppFonts.bodyMedium)
                .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(AppSpacing.md)
            .background(AppColors.inputBackground)
            .cornerRadius(AppCornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(isFocused ? AppColors.primary : AppColors.border, lineWidth: isFocused ? 2 : 1)
            )
        }
    }
}

struct AppIcon: View {
    var body: some View {
        GradientIcon(
            iconName: "doc.text.fill",
            size: 50,
            gradientColors: [AppColors.primary, AppColors.primaryDark]
        )
    }
}

struct AppBranding: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Tender")
                .font(AppFonts.displayLarge)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Connecting Organizations\nwith Vendors")
                .font(AppFonts.bodyLarge)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
}

struct ModernSignInPrompt: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .font(AppFonts.bodyMedium)
                .foregroundColor(AppColors.secondaryText)
            
            Button(action: action) {
                Text("Sign Up")
                    .font(AppFonts.buttonMedium)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}

struct WelcomeHeader: View {
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            AppIcon()
                .scaleEffect(animateIcon ? 1.0 : 0.8)
                .opacity(animateIcon ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: animateIcon)
            
            AppBranding()
                .offset(y: animateText ? 0 : 20)
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.spring(response: 1.0, dampingFraction: 0.7, blendDuration: 0).delay(0.3), value: animateText)
        }
        .onAppear {
            animateIcon = true
            animateText = true
        }
    }
}

struct WelcomeActions: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void
    let onSignUp: () -> Void
    
    @State private var animateButtons = false
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            AnimatedButton(
                title: "Get Started",
                icon: "arrow.right",
                style: .primary,
                action: onGetStarted
            )
            .offset(y: animateButtons ? 0 : 30)
            .opacity(animateButtons ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.6), value: animateButtons)
            
            ModernSignInPrompt(action: onSignUp)
                .offset(y: animateButtons ? 0 : 20)
                .opacity(animateButtons ? 1.0 : 0.0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.8), value: animateButtons)
        }
        .padding(.horizontal, AppSpacing.lg)
        .onAppear {
            animateButtons = true
        }
    }
}

struct ContentView: View {
    @State private var showingSignIn = false
    @State private var showingSignUp = false
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if let currentUser = authService.currentUser {
                    if currentUser.role == .organization {
                        OrganizationDashboardView()
                    } else {
                        VendorMainView()
                    }
                } else {
                    welcomeView
                }
            } else {
                welcomeView
            }
        }
    }
    
    private var welcomeView: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.background,
                            AppColors.primaryLight.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    Circle()
                        .fill(AppColors.primary.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .offset(x: -150, y: -geometry.size.height * 0.3)
                    
                    Circle()
                        .fill(AppColors.primary.opacity(0.03))
                        .frame(width: 200, height: 200)
                        .offset(x: 100, y: geometry.size.height * 0.4)
                    
                    VStack(spacing: AppSpacing.xxxl) {
                        Spacer(minLength: AppSpacing.xl)
                        
                        WelcomeHeader()
                        
                        Spacer(minLength: AppSpacing.lg)
                        
                        WelcomeActions(
                            onGetStarted: handleGetStarted,
                            onSignIn: handleSignIn,
                            onSignUp: handleSignUp
                        )
                        
                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .sheet(isPresented: $showingSignIn) {
                SignInView()
                    .environment(authService)
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
                    .environment(authService)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleGetStarted() {
        showingSignIn = true
    }
    
    private func handleSignIn() {
        showingSignIn = true
    }
    
    private func handleSignUp() {
        showingSignUp = true
    }
}

#Preview {
    ContentView()
        .environment(AuthenticationService())
}
