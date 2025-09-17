import SwiftUI
import SwiftData

struct ViewTenderDetails: View {
    let tender: TenderData
    let isOrganizationView: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingManageOptions = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEditView = false
    
    init(tender: TenderData, isOrganizationView: Bool = false) {
        self.tender = tender
        self.isOrganizationView = isOrganizationView
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tender.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColors.primaryText)
                                .multilineTextAlignment(.leading)
                            
                            Text("Tender Details")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        StatusBadge(text: tender.status.rawValue.capitalized)
                    }
                        
                        HStack(spacing: 16) {
                            InfoChip(icon: "calendar", text: "Due: \(tender.deadline)")
                            InfoChip(icon: "location", text: tender.location.isEmpty ? "Remote" : tender.location)
                        }
                    }
                    
                    VStack(spacing: 24) {
                        if !tender.category.isEmpty {
                            DetailSectionText(title: "Category", content: tender.category)
                        }
                        
                        if !tender.minimumBudget.isEmpty || !tender.maximumBudget.isEmpty {
                            DetailSection(title: "Budget Range") {
                                HStack(spacing: 16) {
                                    if !tender.minimumBudget.isEmpty {
                                        BudgetCard(title: "Minimum", amount: tender.minimumBudget)
                                    }
                                    if !tender.maximumBudget.isEmpty {
                                        BudgetCard(title: "Maximum", amount: tender.maximumBudget)
                                    }
                                }
                            }
                        }
                        
                        if !tender.projectDescription.isEmpty {
                            DetailSectionText(title: "Project Description", content: tender.projectDescription)
                        }
                        
                        if !tender.requirements.isEmpty {
                            DetailSectionText(title: "Requirements", content: tender.requirements)
                        }
                        
                        DetailSection(title: "Tender Information") {
                            VStack(spacing: 12) {
                                InfoRow(label: "Tender ID", value: String(tender.id.uuidString.prefix(8)).uppercased())
                                InfoRow(label: "Created", value: formatDate(tender.dateCreated))
                                InfoRow(label: "Status", value: tender.status.rawValue.capitalized)
                            }
                        }
                    }
                    
                    if tender.status == .active {
                        VStack(spacing: 12) {
                            if isOrganizationView {
                                // Organization view - show Manage Tender button
                                Button(action: {
                                    showingManageOptions = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Manage Tender")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(AppColors.primary)
                                    )
                                }
                            } else {
                                // Vendor view - show Submit Proposal button
                                Button(action: {
                                    
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Submit Proposal")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(AppColors.primary)
                                    )
                                }
                            }
                            
                            if !isOrganizationView {
                                Button(action: {
                                    
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "heart")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Save to Favorites")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(AppColors.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.primary, lineWidth: 1)
                                            .fill(Color.clear)
                                    )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 60)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .actionSheet(isPresented: $showingManageOptions) {
            ActionSheet(
                title: Text("Manage Tender"),
                message: Text("Choose an action for this tender"),
                buttons: [
                    .default(Text("Edit Tender Details")) {
                        showingEditView = true
                    },
                    .destructive(Text("Close Tender")) {
                        closeTender()
                    },
                    .destructive(Text("Delete Tender")) {
                        showingDeleteConfirmation = true
                    },
                    .cancel()
                ]
            )
        }
        .alert("Delete Tender", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTender()
            }
        } message: {
            Text("Are you sure you want to delete this tender? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditView) {
            EditTenderView(tender: tender)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func closeTender() {
        tender.status = .closed
        do {
            try modelContext.save()
        } catch {
            print("Error closing tender: \(error)")
        }
    }
    
    private func deleteTender() {
        modelContext.delete(tender)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting tender: \(error)")
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let content: Content?
    let textContent: String?
    
    init(title: String, content: String) {
        self.title = title
        self.content = nil
        self.textContent = content
    }
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.textContent = nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            if let textContent = textContent {
                Text(textContent)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let content = content {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
        )
    }
}

struct DetailSectionText: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
        )
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.primary)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.primary.opacity(0.1))
        )
    }
}

struct BudgetCard: View {
    let title: String
    let amount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Text("$\(amount)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
        }
    }
}


