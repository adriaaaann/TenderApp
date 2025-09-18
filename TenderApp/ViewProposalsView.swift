import SwiftUI
import SwiftData

struct ViewProposalsView: View {
    let tender: TenderData
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var proposals: [ProposalData]
    
    init(tender: TenderData) {
        self.tender = tender
        let tenderId = tender.id
        self._proposals = Query(
            filter: #Predicate<ProposalData> { proposal in
                proposal.tenderId == tenderId
            },
            sort: \ProposalData.dateSubmitted,
            order: .reverse
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppFonts.labelMedium)
                    .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Proposals")
                            .font(AppFonts.headingLarge)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("\(proposals.count)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button("") { }
                        .font(AppFonts.labelMedium)
                        .opacity(0)
                        .disabled(true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppColors.surfaceBackground)
                
                Divider()
                    .foregroundColor(AppColors.separator)
                
                if proposals.isEmpty {
                    MinimalEmptyProposalsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(proposals, id: \.id) { proposal in
                                MinimalProposalRow(proposal: proposal)
                                    .background(AppColors.surfaceBackground)
                            }
                        }
                    }
                    .background(AppColors.subtleBackground)
                }
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
        }
    }
}

struct MinimalEmptyProposalsView: View {
    var body: some View {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "doc.text")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundColor(AppColors.tertiaryText)
                    
                VStack(spacing: 8) {
                    Text("No proposals yet")
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.primaryText)
                
                Text("Proposals will appear here once submitted")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.surfaceBackground)
    }
}

struct ProposalRowView: View {
    let proposal: ProposalData
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: {
            showingDetails = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(proposal.proposalTitle)
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("by \(proposal.companyName) - \(proposal.contactPerson)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        ProposalStatusBadge(status: proposal.status)
                        
                        Text(proposal.dateSubmitted, style: .date)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                HStack {
                    Label(proposal.proposedBudget, systemImage: "dollarsign.circle")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Label(proposal.timeline, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                if !proposal.proposalDescription.isEmpty {
                    Text(proposal.proposalDescription)
                        .font(.body)
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            ProposalDetailView(proposal: proposal)
        }
    }
}

struct ProposalStatusBadge: View {
    let status: ProposalStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(status.color).opacity(0.2))
            .foregroundColor(Color(status.color))
            .cornerRadius(8)
    }
}

struct MinimalProposalRow: View {
    let proposal: ProposalData
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: {
            showingDetails = true
        }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(proposal.proposalTitle)
                            .font(AppFonts.headingMedium)
                            .foregroundColor(AppColors.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text("by \(proposal.companyName)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        MinimalStatusBadge(status: proposal.status)
                        
                        Text(proposal.proposedBudget)
                            .font(AppFonts.labelSmall)
                            .foregroundColor(AppColors.primaryText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                HStack {
                    Text(proposal.dateSubmitted, style: .date)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .buttonStyle(MinimalRowButtonStyle())
        .sheet(isPresented: $showingDetails) {
            MinimalProposalDetailView(proposal: proposal)
        }
    }
}

struct MinimalRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? AppColors.hover : AppColors.surfaceBackground)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MinimalStatusBadge: View {
    let status: ProposalStatus
    
    var statusColor: Color {
        switch status {
        case .pending:
            return AppColors.secondaryText
        case .accepted:
            return AppColors.success
        case .rejected:
            return AppColors.error
        }
    }
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(AppFonts.overline)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct ProposalDetailView: View {
    let proposal: ProposalData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ProposalDetailHeaderView(proposal: proposal)
                    ProposalContactInfoView(proposal: proposal)
                    ProposalBudgetTimelineView(proposal: proposal)
                    ProposalDescriptionView(proposal: proposal)
                    
                    if !proposal.experience.isEmpty {
                        ProposalExperienceView(proposal: proposal)
                    }
                    
                    if !proposal.attachments.isEmpty {
                        ProposalAttachmentsView(proposal: proposal)
                    }
                }
                .padding(24)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Proposal Details")
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                }
            }
        }
    }
}

struct ProposalDetailHeaderView: View {
    let proposal: ProposalData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(proposal.proposalTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("by \(proposal.companyName) - \(proposal.contactPerson)")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                ProposalStatusBadge(status: proposal.status)
            }
            
            Text("Submitted on \(proposal.dateSubmitted, style: .date)")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

struct ProposalContactInfoView: View {
    let proposal: ProposalData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Email", systemImage: "envelope")
                    Spacer()
                    Text(proposal.email)
                        .foregroundColor(AppColors.primary)
                }
                
                if !proposal.phone.isEmpty {
                    HStack {
                        Label("Phone", systemImage: "phone")
                        Spacer()
                        Text(proposal.phone)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .padding(16)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct ProposalBudgetTimelineView: View {
    let proposal: ProposalData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget & Timeline")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Proposed Budget", systemImage: "dollarsign.circle")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(proposal.proposedBudget)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Timeline", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(proposal.timeline)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct ProposalDescriptionView: View {
    let proposal: ProposalData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Proposal Description")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            Text(proposal.proposalDescription)
                .font(.body)
                .foregroundColor(AppColors.primaryText)
                .padding(16)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
        }
    }
}

struct ProposalExperienceView: View {
    let proposal: ProposalData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Experience & Qualifications")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            Text(proposal.experience)
                .font(.body)
                .foregroundColor(AppColors.primaryText)
                .padding(16)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
        }
    }
}

struct ProposalAttachmentsView: View {
    let proposal: ProposalData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attachments")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(proposal.attachments, id: \.self) { attachment in
                    HStack {
                        Image(systemName: "doc")
                            .foregroundColor(AppColors.primary)
                        
                        Text(attachment)
                            .font(.body)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            // Handle attachment download/view
                        }) {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct MinimalProposalDetailView: View {
    let proposal: ProposalData
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @State private var selectedStatus: ProposalStatus
    
    init(proposal: ProposalData) {
        self.proposal = proposal
        self._selectedStatus = State(initialValue: .pending)
    }
    
    var statusBackgroundColor: Color {
        switch selectedStatus {
        case .pending:
            return Color.gray
        case .accepted:
            return Color.green
        case .rejected:
            return Color.red
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Button("Close") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .font(AppFonts.labelMedium)
                            .foregroundColor(AppColors.secondaryText)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(proposal.proposalTitle)
                                .font(AppFonts.titleLarge)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("by \(proposal.companyName)")
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Status")
                                    .font(AppFonts.overline)
                                    .foregroundColor(AppColors.secondaryText)
                                    .textCase(.uppercase)
                                
                                Menu {
                                    let allowedStatuses: [ProposalStatus] = [.pending, .accepted, .rejected]
                                    ForEach(allowedStatuses, id: \.self) { status in
                                        Button(action: {
                                            selectedStatus = status
                                            updateProposalStatus()
                                        }) {
                                            HStack {
                                                Text(status.rawValue.capitalized)
                                                if status == selectedStatus {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(selectedStatus.rawValue.capitalized)
                                            .font(AppFonts.bodyMedium)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(statusBackgroundColor.opacity(0.15))
                                            .foregroundColor(statusBackgroundColor)
                                            .cornerRadius(12)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.primaryText)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Text(proposal.dateSubmitted, style: .date)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Budget")
                                    .font(AppFonts.overline)
                                    .foregroundColor(AppColors.secondaryText)
                                    .textCase(.uppercase)
                                
                                Text(proposal.proposedBudget)
                                    .font(AppFonts.headingLarge)
                                    .foregroundColor(AppColors.primaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Timeline")
                                    .font(AppFonts.overline)
                                    .foregroundColor(AppColors.secondaryText)
                                    .textCase(.uppercase)
                                
                                Text(proposal.timeline)
                                    .font(AppFonts.headingMedium)
                                    .foregroundColor(AppColors.primaryText)
                            }
                        }
                        
                        Divider()
                            .foregroundColor(AppColors.separator)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(AppFonts.overline)
                                .foregroundColor(AppColors.secondaryText)
                                .textCase(.uppercase)
                            
                            Text(proposal.proposalDescription)
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(AppColors.primaryText)
                                .lineSpacing(4)
                        }
                        
                        if !proposal.experience.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Experience")
                                    .font(AppFonts.overline)
                                    .foregroundColor(AppColors.secondaryText)
                                    .textCase(.uppercase)
                                
                                Text(proposal.experience)
                                    .font(AppFonts.bodyMedium)
                                    .foregroundColor(AppColors.primaryText)
                                    .lineSpacing(4)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact")
                                .font(AppFonts.overline)
                                .foregroundColor(AppColors.secondaryText)
                                .textCase(.uppercase)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(proposal.contactPerson)
                                    .font(AppFonts.bodyMedium)
                                    .foregroundColor(AppColors.primaryText)
                                
                                Text(proposal.email)
                                    .font(AppFonts.bodySmall)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                if !proposal.phone.isEmpty {
                                    Text(proposal.phone)
                                        .font(AppFonts.bodySmall)
                                        .foregroundColor(AppColors.secondaryText)
                                }
                            }
                        }
                        
                        if !proposal.attachments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Attachments")
                                    .font(AppFonts.overline)
                                    .foregroundColor(AppColors.secondaryText)
                                    .textCase(.uppercase)
                                
                                Text(proposal.attachments.joined(separator: ", "))
                                    .font(AppFonts.bodySmall)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(AppColors.surfaceBackground)
            .navigationBarHidden(true)
            .onAppear {
                // Set status to pending when view appears
                selectedStatus = .pending
                proposal.status = .pending
                do {
                    try modelContext.save()
                } catch {
                    print("Failed to initialize proposal status: \(error)")
                }
            }
        }
    }
    
    private func updateProposalStatus() {
        // Update the proposal's status in the database
        proposal.status = selectedStatus
        
        do {
            try modelContext.save()
            print("Successfully updated proposal status to: \(selectedStatus.rawValue)")
        } catch {
            print("Failed to update proposal status: \(error)")
            // Revert the selectedStatus if save failed
            selectedStatus = proposal.status
        }
    }
}

#Preview {
    let sampleProposal = ProposalData(
        tenderId: UUID(),
        vendorEmail: "vendor@example.com",
        vendorName: "John Smith",
        companyName: "Tech Solutions Inc.",
        contactPerson: "John Smith",
        email: "vendor@example.com",
        phone: "+1-555-0123",
        proposalTitle: "Comprehensive Mobile App Development Solution",
        proposedBudget: "$50,000",
        timeline: "3 months",
        proposalDescription: "We propose to develop a comprehensive mobile application that meets all your requirements. Our team has extensive experience in mobile development and we're confident we can deliver a high-quality product within the specified timeframe.",
        experience: "Our team has 10+ years of experience in mobile app development, having delivered over 50 successful projects.",
        attachments: ["portfolio.pdf", "certificates.pdf"]
    )
    
    ProposalDetailView(proposal: sampleProposal)
        .environment(AuthenticationService())
        .modelContainer(for: [TenderData.self, User.self, ProposalData.self], inMemory: true)
}
