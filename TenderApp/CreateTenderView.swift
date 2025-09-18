import SwiftUI
import SwiftData

struct CreateTenderView: View {
    @State private var tenderTitle = ""
    @State private var category = ""
    @State private var location = ""
    @State private var deadline = ""
    @State private var minimumBudget = ""
    @State private var maximumBudget = ""
    @State private var projectDescription = ""
    @State private var requirements = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Tender")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Fill out the details for your new tender")
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
                        
                        FormSection(title: "Attachments") {
                            AttachmentUploadArea()
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            publishTender()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Publish Tender")
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
                            saveAsDraft()
                        }) {
                            Text("Save as Draft")
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
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func publishTender() {
        guard isFormValid() else { return }
        
        let tender = TenderData(
            title: tenderTitle,
            category: category,
            location: location,
            deadline: deadline,
            minimumBudget: minimumBudget,
            maximumBudget: maximumBudget,
            projectDescription: projectDescription,
            requirements: requirements,
            status: .active
        )
        
        modelContext.insert(tender)
        
        do {
            try modelContext.save()
            
            NotificationService.shared.notifyVendorsOfNewTender(tender: tender, modelContext: modelContext)
            
            dismiss()
        } catch {
            print("Error saving tender: \(error)")
        }
    }
    
    private func saveAsDraft() {
        guard !tenderTitle.isEmpty else { return }
        
        let tender = TenderData(
            title: tenderTitle,
            category: category,
            location: location,
            deadline: deadline,
            minimumBudget: minimumBudget,
            maximumBudget: maximumBudget,
            projectDescription: projectDescription,
            requirements: requirements,
            status: .draft
        )
        
        modelContext.insert(tender)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving draft: \(error)")
        }
    }
    
    private func isFormValid() -> Bool {
        return !tenderTitle.isEmpty && !deadline.isEmpty && !projectDescription.isEmpty && !requirements.isEmpty
    }
}

struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MinimalFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    
    init(title: String, placeholder: String, text: Binding<String>, isRequired: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.error)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(text.isEmpty ? AppColors.border : AppColors.primary.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

struct MinimalTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    
    init(title: String, placeholder: String, text: Binding<String>, isRequired: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.error)
                }
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(text.isEmpty ? AppColors.border : AppColors.primary.opacity(0.3), lineWidth: 1)
                    )
                    .frame(height: 100)
                
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.tertiaryText)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                }
                
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
        }
    }
}

struct AttachmentUploadArea: View {
    var body: some View {
        Button(action: {
        }) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary)
                
                VStack(spacing: 4) {
                    Text("Upload Documents")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("PDF, DOC, XLS files supported")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.primary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.primary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                    )
            )
        }
    }
}

#Preview {
    CreateTenderView()
        .preferredColorScheme(.light)
}
