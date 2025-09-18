import SwiftUI
import SwiftData

struct EditTenderView: View {
    @State private var tenderTitle: String
    @State private var category: String
    @State private var location: String
    @State private var deadline: String
    @State private var minimumBudget: String
    @State private var maximumBudget: String
    @State private var projectDescription: String
    @State private var requirements: String
    
    let tender: TenderData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(tender: TenderData) {
        self.tender = tender
        self._tenderTitle = State(initialValue: tender.title)
        self._category = State(initialValue: tender.category)
        self._location = State(initialValue: tender.location)
        self._deadline = State(initialValue: tender.deadline)
        self._minimumBudget = State(initialValue: tender.minimumBudget)
        self._maximumBudget = State(initialValue: tender.maximumBudget)
        self._projectDescription = State(initialValue: tender.projectDescription)
        self._requirements = State(initialValue: tender.requirements)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Tender")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Update the details for your tender")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 28) {
                        FormSection(title: "Basic Information") {
                            VStack(spacing: 16) {
                                MinimalFormField(title: "Tender Title", placeholder: "Enter title", text: $tenderTitle, isRequired: true)
                                MinimalFormField(title: "Category", placeholder: "e.g., Technology, Services", text: $category)
                                MinimalFormField(title: "Location", placeholder: "Project location", text: $location)
                                MinimalFormField(title: "Deadline", placeholder: "dd/mm/yyyy", text: $deadline, isRequired: true)
                            }
                        }
                        
                        FormSection(title: "Budget Range") {
                            HStack(spacing: 16) {
                                MinimalFormField(title: "Minimum", placeholder: "0", text: $minimumBudget)
                                MinimalFormField(title: "Maximum", placeholder: "0", text: $maximumBudget)
                            }
                        }
                        
                        FormSection(title: "Details") {
                            VStack(spacing: 16) {
                                MinimalTextEditor(title: "Description", placeholder: "Describe your project...", text: $projectDescription, isRequired: true)
                                MinimalTextEditor(title: "Requirements", placeholder: "List specific requirements...", text: $requirements, isRequired: true)
                            }
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            updateTender()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Update Tender")
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
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.secondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.border, lineWidth: 1)
                                        .fill(Color.clear)
                                )
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
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.secondaryText)
                }
            }
        }
    }
    
    private func updateTender() {
        guard isFormValid() else { return }
        
        tender.title = tenderTitle
        tender.category = category
        tender.location = location
        tender.deadline = deadline
        tender.minimumBudget = minimumBudget
        tender.maximumBudget = maximumBudget
        tender.projectDescription = projectDescription
        tender.requirements = requirements
        
        do {
            try modelContext.save()
            
            NotificationService.shared.notifyVendorsOfTenderUpdate(tender: tender, modelContext: modelContext)
            
            dismiss()
        } catch {
            print("Error updating tender: \(error)")
        }
    }
    
    private func isFormValid() -> Bool {
        return !tenderTitle.isEmpty && !deadline.isEmpty && !projectDescription.isEmpty && !requirements.isEmpty
    }
}

#Preview {
    EditTenderView(tender: TenderData(
        title: "Sample Tender",
        category: "Technology",
        location: "Remote",
        deadline: "31/12/2024",
        minimumBudget: "5000",
        maximumBudget: "10000",
        projectDescription: "Sample description",
        requirements: "Sample requirements",
        status: .active
    ))
    .environment(AuthenticationService())
    .modelContainer(for: [TenderData.self, User.self], inMemory: true)
    .preferredColorScheme(.light)
}
