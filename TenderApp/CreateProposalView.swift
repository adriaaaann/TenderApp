import SwiftUI
import SwiftData

struct CreateProposalView: View {
    let tender: TenderData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var companyName = ""
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var proposedBudget = ""
    @State private var timeline = ""
    @State private var proposalDescription = ""
    @State private var experience = ""
    @State private var attachments: [String] = []
    @State private var showingSuccessAlert = false
    
    init(tender: TenderData) {
        self.tender = tender
        print("CreateProposalView initialized for tender: \(tender.title)")
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        ProposalHeaderSection(tender: tender)
                        
                        CompanyDetailsSection(
                            companyName: $companyName,
                            contactPerson: $contactPerson,
                            email: $email,
                            phone: $phone
                        )
                        
                        ProposalDetailsSection(
                            proposedBudget: $proposedBudget,
                            timeline: $timeline,
                            proposalDescription: $proposalDescription,
                            experience: $experience
                        )
                        
                        AttachmentsSection(attachments: $attachments)
                        
                        SubmitProposalButton {
                            submitProposal()
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .frame(minHeight: geometry.size.height)
                }
                .background(AppColors.background)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Submit Proposal")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                }
            }
        }
        .alert("Proposal Submitted", isPresented: $showingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your proposal has been submitted successfully. You will be notified when the organization reviews your submission.")
        }
    }
    
    private func submitProposal() {
        // Here you would typically save the proposal to your data model
        // For now, we'll just show the success alert
        showingSuccessAlert = true
    }
}

struct ProposalHeaderSection: View {
    let tender: TenderData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposal for:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(tender.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                StatusBadge(text: tender.status.rawValue)
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
                    Text("Deadline: \(formatDate(tender.deadline))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct CompanyDetailsSection: View {
    @Binding var companyName: String
    @Binding var contactPerson: String
    @Binding var email: String
    @Binding var phone: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Company Details")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 16) {
                ProposalInputField(
                    title: "Company Name",
                    placeholder: "Enter your company name",
                    text: $companyName,
                    isRequired: true
                )
                
                ProposalInputField(
                    title: "Contact Person",
                    placeholder: "Enter contact person name",
                    text: $contactPerson,
                    isRequired: true
                )
                
                ProposalInputField(
                    title: "Email Address",
                    placeholder: "Enter email address",
                    text: $email,
                    isRequired: true,
                    keyboardType: .emailAddress
                )
                
                ProposalInputField(
                    title: "Phone Number",
                    placeholder: "Enter phone number",
                    text: $phone,
                    isRequired: true,
                    keyboardType: .phonePad
                )
            }
        }
    }
}

struct ProposalDetailsSection: View {
    @Binding var proposedBudget: String
    @Binding var timeline: String
    @Binding var proposalDescription: String
    @Binding var experience: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Proposal Details")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 16) {
                ProposalInputField(
                    title: "Proposed Budget",
                    placeholder: "Enter your proposed budget (e.g., $50,000)",
                    text: $proposedBudget,
                    isRequired: true,
                    keyboardType: .decimalPad
                )
                
                ProposalInputField(
                    title: "Project Timeline",
                    placeholder: "Enter estimated timeline (e.g., 3 months)",
                    text: $timeline,
                    isRequired: true
                )
                
                ProposalTextArea(
                    title: "Proposal Description",
                    placeholder: "Describe your approach, methodology, and how you plan to execute this project...",
                    text: $proposalDescription,
                    isRequired: true
                )
                
                ProposalTextArea(
                    title: "Relevant Experience",
                    placeholder: "Describe your relevant experience, past projects, and qualifications...",
                    text: $experience,
                    isRequired: true
                )
            }
        }
    }
}

struct AttachmentsSection: View {
    @Binding var attachments: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Attachments")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 16) {
                Button(action: {
                    // Simulate adding an attachment
                    attachments.append("Portfolio.pdf")
                }) {
                    HStack {
                        Image(systemName: "paperclip")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Add Documents")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.primary)
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.primaryLight.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                if !attachments.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(attachments, id: \.self) { attachment in
                            HStack {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary)
                                
                                Text(attachment)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.primaryText)
                                
                                Spacer()
                                
                                Button(action: {
                                    attachments.removeAll { $0 == attachment }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.secondaryText)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.cardBackground)
                            )
                        }
                    }
                }
                
                Text("Optional: Attach relevant documents like portfolio, certificates, or previous work samples.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct ProposalInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    let keyboardType: UIKeyboardType
    
    init(title: String, placeholder: String, text: Binding<String>, isRequired: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
                .keyboardType(keyboardType)
        }
    }
}

struct ProposalTextArea: View {
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
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryText)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            
            TextEditor(text: $text)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.inputBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
                .overlay(
                    VStack {
                        HStack {
                            Text(text.isEmpty ? placeholder : "")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.secondaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                            Spacer()
                        }
                        Spacer()
                    }
                    .allowsHitTesting(false)
                )
        }
    }
}

struct SubmitProposalButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Submit Proposal")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppColors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.top, 20)
    }
}

#Preview {
    CreateProposalView(tender: TenderData(
        title: "Mobile App Development",
        category: "IT Services",
        location: "New York, NY",
        deadline: "30/10/2025",
        minimumBudget: "50000",
        maximumBudget: "75000",
        projectDescription: "We are looking for a skilled mobile app development team to create a cross-platform mobile application for our business.",
        requirements: "Experience with React Native or Flutter, portfolio of previous mobile apps, ability to integrate with REST APIs."
    ))
    .modelContainer(for: TenderData.self, inMemory: true)
}
