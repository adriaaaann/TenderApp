import SwiftUI
import SwiftData

struct ViewProposalsView: View {
    let tender: TenderData
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var proposals: [ProposalData]
    @State private var rankedProposals: [ProposalRankingService.RankedProposal] = []
    @State private var showRankedView = false
    
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
                    
                    if !proposals.isEmpty {
                        Button(showRankedView ? "Date" : "Rank") {
                            if !showRankedView {
                                rankProposals()
                            }
                            showRankedView.toggle()
                        }
                        .font(AppFonts.labelMedium)
                        .foregroundColor(AppColors.primary)
                    } else {
                        Button("") { }
                            .font(AppFonts.labelMedium)
                            .opacity(0)
                            .disabled(true)
                    }
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
                            if showRankedView {
                                ForEach(rankedProposals, id: \.proposal.id) { rankedProposal in
                                    RankedProposalRow(rankedProposal: rankedProposal)
                                        .background(AppColors.surfaceBackground)
                                }
                            } else {
                                ForEach(proposals, id: \.id) { proposal in
                                    MinimalProposalRow(proposal: proposal)
                                        .background(AppColors.surfaceBackground)
                                }
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
    
    private func rankProposals() {
        rankedProposals = ProposalRankingService.rankProposals(proposals, for: tender)
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

struct RankedProposalRow: View {
    let rankedProposal: ProposalRankingService.RankedProposal
    @State private var showingDetails = false
    
    private var rankColor: Color {
        switch rankedProposal.rank {
        case 1:
            return Color.green
        case 2:
            return Color.orange
        case 3:
            return Color.blue
        default:
            return AppColors.secondaryText
        }
    }
    
    private var confidenceColor: Color {
        switch rankedProposal.confidence {
        case "High":
            return Color.green
        case "Medium":
            return Color.orange
        case "Low":
            return Color.red
        default:
            return AppColors.secondaryText
        }
    }
    
    var body: some View {
        Button(action: {
            showingDetails = true
        }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 16) {
                    // Rank Badge
                    VStack {
                        Text("#\(rankedProposal.rank)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(rankColor)
                            .clipShape(Circle())
                        
                        Text(String(format: "%.0f", rankedProposal.overallScore))
                            .font(.caption)
                            .foregroundColor(rankColor)
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(rankedProposal.proposal.proposalTitle)
                            .font(AppFonts.headingMedium)
                            .foregroundColor(AppColors.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text("by \(rankedProposal.proposal.companyName)")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.secondaryText)
                        
                        // Strengths
                        if !rankedProposal.strengths.isEmpty {
                            HStack {
                                ForEach(rankedProposal.strengths.prefix(2), id: \.self) { strength in
                                    Text(strength)
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                if rankedProposal.strengths.count > 2 {
                                    Text("+\(rankedProposal.strengths.count - 2)")
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryText)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        MinimalStatusBadge(status: rankedProposal.proposal.status)
                        
                        Text(rankedProposal.proposal.proposedBudget)
                            .font(AppFonts.labelSmall)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(rankedProposal.confidence)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(confidenceColor)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                HStack {
                    Text(rankedProposal.proposal.dateSubmitted, style: .date)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Spacer()
                    
                    // Score breakdown preview
                    Text("Budget: \(Int(rankedProposal.individualScores.budgetScore)) • Quality: \(Int(rankedProposal.individualScores.qualityScore))")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                    
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
            RankedProposalDetailView(rankedProposal: rankedProposal)
        }
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

struct RankedProposalDetailView: View {
    let rankedProposal: ProposalRankingService.RankedProposal
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @State private var selectedStatus: ProposalStatus
    
    init(rankedProposal: ProposalRankingService.RankedProposal) {
        self.rankedProposal = rankedProposal
        self._selectedStatus = State(initialValue: rankedProposal.proposal.status)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Ranking Overview
                    VStack(spacing: 16) {
                        HStack {
                            VStack {
                                Text("#\(rankedProposal.rank)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 64, height: 64)
                                    .background(rankColor)
                                    .clipShape(Circle())
                                
                                Text("RANK")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.1f", rankedProposal.overallScore))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(AppColors.primaryText)
                                
                                Text("OVERALL SCORE")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Text(rankedProposal.confidence + " Confidence")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(confidenceColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(confidenceColor.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(20)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                    }
                    
                    // Score Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Score Breakdown")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                        
                        VStack(spacing: 12) {
                            ScoreBar(title: "Budget Competitiveness", score: rankedProposal.individualScores.budgetScore, color: .blue)
                            ScoreBar(title: "Technical Capability", score: rankedProposal.individualScores.technicalScore, color: .purple)
                            ScoreBar(title: "Proposal Quality", score: rankedProposal.individualScores.qualityScore, color: .green)
                            ScoreBar(title: "Vendor Reputation", score: rankedProposal.individualScores.reputationScore, color: .orange)
                            ScoreBar(title: "Timeline Feasibility", score: rankedProposal.individualScores.timelineScore, color: .cyan)
                            ScoreBar(title: "Communication", score: rankedProposal.individualScores.communicationScore, color: .pink)
                        }
                    }
                    .padding(20)
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    
                    // Strengths & Concerns
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Strengths")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            ForEach(rankedProposal.strengths, id: \.self) { strength in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(strength)
                                        .font(.body)
                                        .foregroundColor(AppColors.primaryText)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(12)
                        
                        if !rankedProposal.concerns.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Concerns")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                ForEach(rankedProposal.concerns, id: \.self) { concern in
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text(concern)
                                            .font(.body)
                                            .foregroundColor(AppColors.primaryText)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.orange.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Original Proposal Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Proposal Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                        
                        ProposalDetailHeaderView(proposal: rankedProposal.proposal)
                        ProposalContactInfoView(proposal: rankedProposal.proposal)
                        ProposalBudgetTimelineView(proposal: rankedProposal.proposal)
                        ProposalDescriptionView(proposal: rankedProposal.proposal)
                        
                        if !rankedProposal.proposal.experience.isEmpty {
                            ProposalExperienceView(proposal: rankedProposal.proposal)
                        }
                    }
                    
                    // Status Update
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Proposal Status")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                        
                        Picker("Status", selection: $selectedStatus) {
                            ForEach(ProposalStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedStatus) { _, _ in
                            updateProposalStatus()
                        }
                    }
                    .padding(20)
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
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
                    VStack {
                        Text("Ranked Proposal #\(rankedProposal.rank)")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        Text(rankedProposal.proposal.companyName)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
        }
    }
    
    private var rankColor: Color {
        switch rankedProposal.rank {
        case 1: return Color.green
        case 2: return Color.orange
        case 3: return Color.blue
        default: return AppColors.secondaryText
        }
    }
    
    private var confidenceColor: Color {
        switch rankedProposal.confidence {
        case "High": return Color.green
        case "Medium": return Color.orange
        case "Low": return Color.red
        default: return AppColors.secondaryText
        }
    }
    
    private func updateProposalStatus() {
        rankedProposal.proposal.status = selectedStatus
        
        do {
            try modelContext.save()
            print("Successfully updated proposal status to: \(selectedStatus.rawValue)")
        } catch {
            print("Failed to update proposal status: \(error)")
            selectedStatus = rankedProposal.proposal.status
        }
    }
}

struct ScoreBar: View {
    let title: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text(String(format: "%.0f", score))
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (score / 100), height: 8)
                        .animation(.easeInOut(duration: 0.5), value: score)
                }
            }
            .frame(height: 8)
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
