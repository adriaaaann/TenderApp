import SwiftUI
import SwiftData

struct VendorDashboardView: View {
    @Query(sort: \TenderData.dateCreated, order: .reverse) private var allTenders: [TenderData]
    
    private var openTenders: [TenderData] {
        allTenders.filter { $0.status == .active }
    }
    
    @State private var selectedTender: TenderData?
    @State private var showingTenderDetails = false
    @State private var showingCreateProposal = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    private let categories = ["All", "Construction", "IT Services", "Consulting", "Manufacturing", "Transportation", "Healthcare", "Education", "Finance", "Other"]
    
    private var filteredTenders: [TenderData] {
        var filtered = openTenders
        
        if !searchText.isEmpty {
            filtered = filtered.filter { tender in
                tender.title.localizedCaseInsensitiveContains(searchText) ||
                tender.category.localizedCaseInsensitiveContains(searchText) ||
                tender.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {
                        VendorHeaderSection()
                        
                        SearchAndFilterSection(
                            searchText: $searchText,
                            selectedCategory: $selectedCategory,
                            categories: categories
                        )
                        
                        OpenTendersSection(
                            tenders: filteredTenders,
                            onTenderTap: { tender in
                                selectedTender = tender
                                showingTenderDetails = true
                            },
                            onSubmitProposal: { tender in
                                print("Submit Proposal tapped for: \(tender.title)")
                                selectedTender = tender
                                showingCreateProposal = true
                                print("showingCreateProposal set to: \(showingCreateProposal)")
                            }
                        )
                        
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                VendorBottomTabBar()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTenderDetails) {
            if let selectedTender = selectedTender {
                ViewTenderDetails(tender: selectedTender)
            }
        }
        .sheet(isPresented: $showingCreateProposal) {
            if let selectedTender = selectedTender {
                CreateProposalView(tender: selectedTender)
            }
        }
    }
}

struct VendorHeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vendor Portal")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Browse Open Tenders")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Button(action: {}) {
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
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct SearchAndFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.cardBackground)
                        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.secondaryText)
                            .font(.system(size: 16))
                        
                        TextField("Search tenders...", text: $searchText)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedCategory == category ? .white : AppColors.secondaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedCategory == category ? AppColors.primary : AppColors.cardBackground)
                                )
                                .shadow(color: AppColors.shadow.opacity(0.1), radius: 1, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
}

struct OpenTendersSection: View {
    let tenders: [TenderData]
    let onTenderTap: (TenderData) -> Void
    let onSubmitProposal: (TenderData) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Open Tenders")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("\(tenders.count) Available")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if tenders.isEmpty {
                EmptyTendersView()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(tenders) { tender in
                        TenderCardView(
                            tender: tender,
                            onTap: { onTenderTap(tender) },
                            onSubmitProposal: { onSubmitProposal(tender) }
                        )
                    }
                }
            }
        }
    }
}

struct TenderCardView: View {
    let tender: TenderData
    let onTap: () -> Void
    let onSubmitProposal: () -> Void
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return dateString
    }
    
    private func daysUntilDeadline(_ dateString: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let deadlineDate = formatter.date(from: dateString) {
            let calendar = Calendar.current
            let today = Date()
            let components = calendar.dateComponents([.day], from: today, to: deadlineDate)
            return components.day
        }
        return nil
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tender.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.primaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            HStack {
                                Label(tender.category, systemImage: "tag.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Spacer()
                                
                                StatusBadge(text: tender.status.rawValue)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                        .background(AppColors.border)
                    
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Budget Range")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Text("$\(tender.minimumBudget) - $\(tender.maximumBudget)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Location")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Text(tender.location)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.primaryText)
                            }
                        }
                        
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Text("Deadline: \(formatDate(tender.deadline))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.primaryText)
                            }
                            
                            Spacer()
                            
                            if let daysLeft = daysUntilDeadline(tender.deadline) {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12))
                                        .foregroundColor(daysLeft <= 7 ? .red : AppColors.secondaryText)
                                    
                                    Text(daysLeft > 0 ? "\(daysLeft) days left" : "Expired")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(daysLeft <= 7 ? .red : AppColors.secondaryText)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text(tender.projectDescription)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary)
                            
                            Text("View Details")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: onSubmitProposal) {
                            HStack(spacing: 6) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                
                                Text("Submit Proposal")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyTendersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppColors.secondaryText.opacity(0.5))
            
            Text("No Open Tenders")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text("There are currently no open tenders matching your criteria. Check back later for new opportunities.")
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
    }
}

struct VendorBottomTabBar: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.shadow.opacity(0.1), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(.container, edges: .bottom)
            
            HStack(spacing: 0) {
                VendorTabButton(
                    icon: "house.fill",
                    title: "Browse",
                    isSelected: true
                )
                
                VendorTabButton(
                    icon: "doc.text",
                    title: "My Bids",
                    isSelected: false
                )
                
                VendorTabButton(
                    icon: "bell",
                    title: "Notifications",
                    isSelected: false
                )
                
                VendorTabButton(
                    icon: "person",
                    title: "Profile",
                    isSelected: false
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(height: 88)
    }
}

struct VendorTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.secondaryText)
                
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VendorDashboardView()
        .modelContainer(for: TenderData.self, inMemory: true)
}
