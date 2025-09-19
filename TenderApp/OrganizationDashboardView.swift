import SwiftUI
import SwiftData

struct OrganizationDashboardView: View {
    @State private var selectedTender: TenderData?
    @State private var showingTenderDetails = false
    @State private var showingProposals = false
    @State private var selectedTenderForProposals: TenderData?
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {
                        HeaderSection()
                        
                        StatisticsSection()
                        
                        MyTendersSection(
                            onTenderTap: { tender in
                                selectedTender = tender
                                showingTenderDetails = true
                            },
                            onViewProposals: { tender in
                                selectedTenderForProposals = tender
                                showingProposals = true
                            }
                        )
                        
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                BottomTabBar()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTenderDetails) {
            if let selectedTender = selectedTender {
                ViewTenderDetails(tender: selectedTender, isOrganizationView: true)
            }
        }
        .sheet(isPresented: $showingProposals) {
            if let selectedTenderForProposals = selectedTenderForProposals {
                ViewProposalsView(tender: selectedTenderForProposals)
            }
        }
    }
}

struct HeaderSection: View {
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Organization Portal")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(authService.currentUser?.fullName ?? "Organization")
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
                                    gradient: Gradient(colors: [AppColors.primary, AppColors.primary.opacity(0.7)]),
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
                            Text("ORG")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct StatisticsSection: View {
    @Query private var tenders: [TenderData]
    @Query private var proposals: [ProposalData]
    
    private var activeTenders: Int {
        tenders.filter { $0.status == .active }.count
    }
    
    private var totalProposals: Int {
        // Count all proposals that belong to the organization's tenders
        let tenderIds = Set(tenders.map { $0.id })
        return proposals.filter { tenderIds.contains($0.tenderId) }.count
    }
    
    private var pendingReviews: Int {
        // Count proposals with pending status for all organization's tenders
        let tenderIds = Set(tenders.map { $0.id })
        return proposals.filter { 
            tenderIds.contains($0.tenderId) && $0.status == .pending 
        }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Dashboard Overview")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                StatCard(number: "\(activeTenders)", title: "Active\nTenders", color: AppColors.primary)
                StatCard(number: "\(totalProposals)", title: "Total\nProposals", color: AppColors.success)
                StatCard(number: "\(pendingReviews)", title: "Pending\nReview", color: AppColors.warning)
            }
        }
    }
}

struct StatCard: View {
    let number: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(number)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct MyTendersSection: View {
    @Query(sort: \TenderData.dateCreated, order: .reverse) private var tenders: [TenderData]
    @State private var showingCreateTender = false
    let onTenderTap: (TenderData) -> Void
    let onViewProposals: (TenderData) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Tenders")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                Spacer()
                
                Button("Create New") {
                    showingCreateTender = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.primary)
            }
            .padding(.horizontal, 4)
            
            if tenders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text("No tenders yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("Create your first tender to get started")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.tertiaryText)
                        .multilineTextAlignment(.center)
                    
                    Button("Create Tender") {
                        showingCreateTender = true
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(tenders.prefix(3)), id: \.id) { tender in
                        TenderCard(
                            tender: tender,
                            onViewDetails: {
                                onTenderTap(tender)
                            },
                            onViewProposals: {
                                onViewProposals(tender)
                            }
                        )
                    }
                    
                    if tenders.count > 3 {
                        Button("View All (\(tenders.count))") {
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primary)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateTender) {
            CreateTenderView()
        }
    }
}

struct TenderCard: View {
    let tender: TenderData
    let onViewDetails: () -> Void
    let onViewProposals: () -> Void
    @Query private var proposals: [ProposalData]
    
    private var proposalCount: Int {
        proposals.filter { $0.tenderId == tender.id }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Text(tender.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(2)
                
                Spacer()
                
                StatusBadge(text: tender.status.rawValue)
            }
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primary)
                    
                    Text("\(proposalCount) proposals")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.primary)
                    
                    Text(tender.deadline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            HStack {
                if !tender.category.isEmpty {
                    Text(tender.category)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppColors.primary.opacity(0.1))
                        )
                }
                
                Spacer()
                
                if !tender.minimumBudget.isEmpty && !tender.maximumBudget.isEmpty {
                    Text("$\(tender.minimumBudget) - $\(tender.maximumBudget)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            HStack(spacing: 12) {
                Button("View Details") {
                    onViewDetails()
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
                
                if tender.status == .active {
                    Button("View proposals") {
                        onViewProposals()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppColors.primary)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct StatusBadge: View {
    let text: String
    
    private var badgeColor: Color {
        switch text.lowercased() {
        case "pending":
            return Color.gray
        case "accepted":
            return AppColors.success
        case "rejected":
            return AppColors.error
        default:
            return AppColors.success
        }
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [badgeColor, badgeColor.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(8)
    }
}

struct BottomTabBar: View {
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill", title: "Home", isSelected: true)
            TabBarItem(icon: "plus.circle", title: "Create", isSelected: false)
            TabBarItem(icon: "message.fill", title: "Messages", isSelected: false)
            TabBarItem(icon: "person.circle.fill", title: "Profile", isSelected: false)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.secondaryText)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                isSelected ? AppColors.primary.opacity(0.1) : Color.clear,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    OrganizationDashboardView()
        .environment(AuthenticationService())
        .modelContainer(for: [TenderData.self, User.self, ProposalData.self], inMemory: true)
}
