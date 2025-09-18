import SwiftUI
import SwiftData

struct MyBidsView: View {
    @Binding var selectedTab: Int
    @Environment(AuthenticationService.self) private var authService
    @Environment(\.modelContext) private var modelContext
    @Query private var allProposals: [ProposalData]
    @Query private var allTenders: [TenderData]
    @State private var selectedProposal: ProposalData?
    @State private var selectedTender: TenderData?
    @State private var showingProposalDetails = false
    @State private var showingTenderDetails = false
    
    private var myProposals: [ProposalData] {
        guard let currentUser = authService.currentUser else { return [] }
        return allProposals.filter { $0.vendorEmail == currentUser.email }
            .sorted { $0.dateSubmitted > $1.dateSubmitted }
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                MyBidsHeaderSection()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if myProposals.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(myProposals, id: \.id) { proposal in
                                    MyBidCard(
                                        proposal: proposal,
                                        tender: getTenderForProposal(proposal),
                                        onViewProposal: {
                                            selectedProposal = proposal
                                            showingProposalDetails = true
                                        },
                                        onViewTender: {
                                            if let tender = getTenderForProposal(proposal) {
                                                selectedTender = tender
                                                showingTenderDetails = true
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        
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
        .sheet(isPresented: $showingProposalDetails) {
            if let proposal = selectedProposal {
                VendorProposalDetailView(proposal: proposal)
            }
        }
        .sheet(isPresented: $showingTenderDetails) {
            if let tender = selectedTender {
                ViewTenderDetails(tender: tender)
            }
        }
    }
    
    private func getTenderForProposal(_ proposal: ProposalData) -> TenderData? {
        return allTenders.first { $0.id == proposal.tenderId }
    }
}

struct MyBidsHeaderSection: View {
    @Environment(AuthenticationService.self) private var authService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Bids")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    if let user = authService.currentUser, let company = user.companyName {
                        Text(company)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("View your submitted proposals")
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.secondaryText.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Bids Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Start submitting proposals to see your bids here")
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

struct MyBidCard: View {
    let proposal: ProposalData
    let tender: TenderData?
    let onViewProposal: () -> Void
    let onViewTender: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let tender = tender {
                            Text(tender.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.primaryText)
                                .lineLimit(2)
                        } else {
                            Text("Tender Not Found")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Text(proposal.companyName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    StatusBadge(text: proposal.status.rawValue.capitalized)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Proposed Budget: \(proposal.proposedBudget)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Submitted: \(proposal.dateSubmitted, style: .date)")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    if let tender = tender {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary)
                            
                            Text(tender.location)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
            }
            .padding(20)
            
            Divider()
                .background(AppColors.secondaryText.opacity(0.1))
            
            HStack(spacing: 12) {
                Button(action: onViewProposal) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("View Proposal")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: onViewTender) {
                    HStack(spacing: 8) {
                        Image(systemName: "building.2")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("View Tender")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.primary, AppColors.primary.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(8)
                }
                .disabled(tender == nil)
                .opacity(tender == nil ? 0.5 : 1.0)
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    VendorMainView()
        .environment(AuthenticationService())
}
