import SwiftUI
import SwiftData
import CoreML

struct CreateTenderView: View {
    @State private var tenderTitle = ""
    @State private var category = "IT Services"
    @State private var location = ""
    @State private var deadline = ""
    @State private var minimumBudget = ""
    @State private var maximumBudget = ""
    @State private var projectDescription = ""
    @State private var requirements = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private let categoryOptions = ["Consulting", "IT Services", "Procurement"]
    
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
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Category")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.primaryText)
                                        
                                        Text("(Auto-detected)")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(AppColors.secondaryText)
                                            .italic()
                                    }
                                    
                                    HStack {
                                        Image(systemName: "brain.head.profile")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.primary)
                                        
                                        Text(category)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.primaryText)
                                        
                                        Spacer()
                                        
                                        if !projectDescription.isEmpty || !requirements.isEmpty {
                                            Text("✓ Analyzed")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppColors.cardBackground)
                                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
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
                                    .onChange(of: projectDescription) { oldValue, newValue in
                                        updateCategoryBasedOnContent()
                                    }
                                MinimalTextEditor(title: "Requirements", placeholder: "List specific requirements...", text: $requirements, isRequired: true)
                                    .onChange(of: requirements) { oldValue, newValue in
                                        updateCategoryBasedOnContent()
                                    }
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
    
    private func updateCategoryBasedOnContent() {
        let combinedText = "\(projectDescription) \(requirements)".trimmingCharacters(in: .whitespacesAndNewlines)
        
       
        guard !combinedText.isEmpty && combinedText.count > 10 else {
            category = "IT Services"
            return
        }
        
        
        do {
            let model = try tenderCatergory_(configuration: MLModelConfiguration())
            let prediction = try model.prediction(text: combinedText)
            
            
            print("ML Model prediction successful - using enhanced categorization")
            enhancedKeywordCategorization(combinedText)
            
        } catch {
            print("Core ML model error, using enhanced categorization: \(error)")
            enhancedKeywordCategorization(combinedText)
        }
    }
    
    private func enhancedKeywordCategorization(_ text: String) {
        let lowercaseText = text.lowercased()
        
        var scores = [
            "IT Services": 0.0,
            "Procurement": 0.0, 
            "Consulting": 0.0
        ]
        
        let itKeywords = [
            ("software", 3.0), ("application", 3.0), ("mobile app", 4.0), ("website", 3.0), 
            ("web development", 4.0), ("programming", 3.0), ("database", 3.0), ("api", 3.0),
            ("cloud", 2.0), ("server", 2.0), ("hosting", 2.0), ("cybersecurity", 4.0),
            ("network", 2.0), ("system", 1.0), ("platform", 2.0), ("digital", 2.0), 
            ("technology", 2.0), ("coding", 3.0), ("development", 2.0), ("saas", 4.0),
            ("integration", 3.0), ("automation", 3.0), ("ai", 3.0), ("machine learning", 4.0),
            ("analytics", 3.0), ("crm", 3.0), ("erp", 3.0), ("it support", 4.0),
            ("technical", 2.0), ("infrastructure", 3.0), ("data migration", 4.0)
        ]
        
        let procurementKeywords = [
            ("furniture", 4.0), ("equipment", 3.0), ("supplies", 4.0), ("materials", 3.0),
            ("procurement", 5.0), ("purchase", 4.0), ("office supplies", 5.0), ("stationery", 5.0),
            ("computers", 2.0), ("laptops", 3.0), ("desks", 4.0), ("chairs", 4.0),
            ("inventory", 3.0), ("goods", 3.0), ("products", 2.0), ("hardware", 2.0),
            ("machinery", 3.0), ("tools", 3.0), ("vehicles", 3.0), ("medical equipment", 4.0),
            ("catering", 4.0), ("cleaning supplies", 5.0), ("uniforms", 4.0),
            ("construction materials", 4.0), ("raw materials", 4.0), ("bulk purchase", 5.0),
            ("vendor selection", 4.0)
        ]
        
        let consultingKeywords = [
            ("consulting", 5.0), ("advisory", 4.0), ("strategy", 4.0), ("business analysis", 5.0),
            ("audit", 4.0), ("assessment", 3.0), ("planning", 2.0), ("research", 3.0),
            ("evaluation", 3.0), ("optimization", 4.0), ("training", 3.0), ("workshop", 4.0),
            ("implementation", 2.0), ("change management", 5.0), ("process improvement", 5.0),
            ("feasibility study", 5.0), ("market research", 4.0), ("financial analysis", 4.0),
            ("risk assessment", 4.0), ("compliance review", 4.0), ("organizational development", 5.0),
            ("project management", 3.0), ("strategic planning", 5.0)
        ]
        
        for (keyword, weight) in itKeywords {
            if lowercaseText.contains(keyword) {
                scores["IT Services"]! += weight
            }
        }
        
        for (keyword, weight) in procurementKeywords {
            if lowercaseText.contains(keyword) {
                scores["Procurement"]! += weight
            }
        }
        
        for (keyword, weight) in consultingKeywords {
            if lowercaseText.contains(keyword) {
                scores["Consulting"]! += weight
            }
        }
        
        if let predictedCategory = scores.max(by: { $0.value < $1.value })?.key, scores[predictedCategory]! > 0 {
            category = predictedCategory
            print("Enhanced categorization result: \(predictedCategory) with score: \(scores[predictedCategory]!)")
        } else {
            category = "IT Services"
            print("No clear category match, defaulting to IT Services")
        }
    }
    
    private func fallbackKeywordCategorization(_ text: String) {
        let lowercaseText = text.lowercased()
        
        let itKeywords = [
            "software", "application", "mobile app", "website", "web development", "programming",
            "database", "api", "cloud", "server", "hosting", "cybersecurity", "network",
            "system", "platform", "digital", "technology", "coding", "development",
            "saas", "integration", "automation", "ai", "machine learning", "analytics",
            "crm", "erp", "it support", "technical", "infrastructure", "data migration"
        ]
        
        let procurementKeywords = [
            "furniture", "equipment", "supplies", "materials", "procurement", "purchase",
            "office supplies", "stationery", "computers", "laptops", "desks", "chairs",
            "inventory", "goods", "products", "hardware", "machinery", "tools",
            "vehicles", "medical equipment", "catering", "cleaning supplies", "uniforms",
            "construction materials", "raw materials", "bulk purchase", "vendor selection"
        ]
        
        let consultingKeywords = [
            "consulting", "advisory", "strategy", "business analysis", "audit", "assessment",
            "planning", "research", "evaluation", "optimization", "training", "workshop",
            "implementation", "change management", "process improvement", "feasibility study",
            "market research", "financial analysis", "risk assessment", "compliance review",
            "organizational development", "project management", "strategic planning"
        ]
        
        var scores = [
            "IT Services": 0,
            "Procurement": 0, 
            "Consulting": 0
        ]
        
        for keyword in itKeywords {
            if lowercaseText.contains(keyword) {
                scores["IT Services"]! += 1
            }
        }
        
        for keyword in procurementKeywords {
            if lowercaseText.contains(keyword) {
                scores["Procurement"]! += 1
            }
        }
        
        for keyword in consultingKeywords {
            if lowercaseText.contains(keyword) {
                scores["Consulting"]! += 1
            }
        }
        
        if let predictedCategory = scores.max(by: { $0.value < $1.value })?.key, scores[predictedCategory]! > 0 {
            category = predictedCategory
        } else {
            category = "IT Services"
        }
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
