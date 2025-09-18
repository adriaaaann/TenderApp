import SwiftUI

struct VendorMainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            switch selectedTab {
            case 0:
                VendorDashboardView(selectedTab: $selectedTab)
            case 1:
                MyBidsView(selectedTab: $selectedTab)
            case 2:
                VendorNotificationsView(selectedTab: $selectedTab)
            case 3:
                VendorProfileView(selectedTab: $selectedTab)
            default:
                VendorDashboardView(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
    }
}

struct VendorNotificationsView: View {
    @Binding var selectedTab: Int
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VendorNotificationHeaderSection()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VendorEmptyNotificationsView()
                        
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                VendorBottomTabBar(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
    }
}

struct VendorProfileView: View {
    @Binding var selectedTab: Int
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VendorProfileHeaderSection()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VendorProfileDetailsCard()
                        
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                VendorBottomTabBar(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
    }
}

struct VendorNotificationHeaderSection: View {
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Stay updated with your bids")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Menu {
                    Button("Sign Out", action: {
                        authService.signOut()
                    })
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        if let user = authService.currentUser {
                            let initials = String(user.fullName.prefix(2)).uppercased()
                            Text(initials)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

struct VendorEmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(AppColors.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Notifications")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("You'll see updates about your bids here")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct VendorProfileHeaderSection: View {
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    if let user = authService.currentUser {
                        Text(user.fullName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button("Sign Out", action: {
                        authService.signOut()
                    })
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        if let user = authService.currentUser {
                            let initials = String(user.fullName.prefix(2)).uppercased()
                            Text(initials)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

struct VendorProfileDetailsCard: View {
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Information")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            if let user = authService.currentUser {
                VStack(alignment: .leading, spacing: 16) {
                    VendorDetailRow(title: "Full Name", value: user.fullName)
                    VendorDetailRow(title: "Email", value: user.email)
                    VendorDetailRow(title: "User Type", value: user.role.rawValue.capitalized)
                    
                    if let company = user.companyName {
                        VendorDetailRow(title: "Company", value: company)
                    }
                    
                    VendorDetailRow(title: "Member Since", value: user.createdAt.formatted(date: .abbreviated, time: .omitted))
                }
            }
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.2))
                .padding(.vertical, 8)
            
            Button(action: {
                authService.signOut()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                    
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.red)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct VendorDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(AppColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    VendorMainView()
        .environment(AuthenticationService())
}
