import Foundation
import SwiftData

// MARK: - Proposal Ranking Service
class ProposalRankingService {
    
    // MARK: - Scoring Weights
    private struct ScoringWeights {
        static let budgetCompetitiveness: Double = 0.25
        static let vendorReputation: Double = 0.20
        static let technicalCapability: Double = 0.20
        static let proposalQuality: Double = 0.15
        static let timelineFeasibility: Double = 0.10
        static let communicationResponsiveness: Double = 0.10
    }
    
    // MARK: - Ranked Proposal Model
    struct RankedProposal {
        let proposal: ProposalData
        let overallScore: Double
        let rank: Int
        let confidence: String
        let strengths: [String]
        let concerns: [String]
        let individualScores: IndividualScores
        
        struct IndividualScores {
            let budgetScore: Double
            let reputationScore: Double
            let technicalScore: Double
            let qualityScore: Double
            let timelineScore: Double
            let communicationScore: Double
        }
    }
    
    // MARK: - Main Ranking Function
    static func rankProposals(_ proposals: [ProposalData], for tender: TenderData) -> [RankedProposal] {
        guard !proposals.isEmpty else { return [] }
        
        let scoredProposals = proposals.map { proposal in
            let scores = calculateIndividualScores(for: proposal, tender: tender)
            let overallScore = calculateOverallScore(from: scores)
            let strengths = identifyStrengths(from: scores, proposal: proposal)
            let concerns = identifyConcerns(from: scores, proposal: proposal, tender: tender)
            
            return (proposal: proposal, score: overallScore, scores: scores, strengths: strengths, concerns: concerns)
        }
        
        // Sort by score (highest first)
        let sortedProposals = scoredProposals.sorted { $0.score > $1.score }
        
        // Apply tie-breaking rules and create ranked proposals
        return sortedProposals.enumerated().map { index, scoredProposal in
            let confidence = getConfidenceLevel(score: scoredProposal.score, rank: index + 1, totalCount: proposals.count)
            
            return RankedProposal(
                proposal: scoredProposal.proposal,
                overallScore: scoredProposal.score,
                rank: index + 1,
                confidence: confidence,
                strengths: scoredProposal.strengths,
                concerns: scoredProposal.concerns,
                individualScores: RankedProposal.IndividualScores(
                    budgetScore: scoredProposal.scores.budget,
                    reputationScore: scoredProposal.scores.reputation,
                    technicalScore: scoredProposal.scores.technical,
                    qualityScore: scoredProposal.scores.quality,
                    timelineScore: scoredProposal.scores.timeline,
                    communicationScore: scoredProposal.scores.communication
                )
            )
        }
    }
    
    // MARK: - Individual Score Calculations
    private struct IndividualScores {
        let budget: Double
        let reputation: Double
        let technical: Double
        let quality: Double
        let timeline: Double
        let communication: Double
    }
    
    private static func calculateIndividualScores(for proposal: ProposalData, tender: TenderData) -> IndividualScores {
        return IndividualScores(
            budget: calculateBudgetScore(proposal: proposal, tender: tender),
            reputation: calculateReputationScore(proposal: proposal),
            technical: calculateTechnicalScore(proposal: proposal, tender: tender),
            quality: calculateQualityScore(proposal: proposal),
            timeline: calculateTimelineScore(proposal: proposal, tender: tender),
            communication: calculateCommunicationScore(proposal: proposal)
        )
    }
    
    private static func calculateOverallScore(from scores: IndividualScores) -> Double {
        let weighted = scores.budget * ScoringWeights.budgetCompetitiveness +
                      scores.reputation * ScoringWeights.vendorReputation +
                      scores.technical * ScoringWeights.technicalCapability +
                      scores.quality * ScoringWeights.proposalQuality +
                      scores.timeline * ScoringWeights.timelineFeasibility +
                      scores.communication * ScoringWeights.communicationResponsiveness
        
        return min(100.0, max(0.0, weighted))
    }
    
    // MARK: - Budget Scoring
    private static func calculateBudgetScore(proposal: ProposalData, tender: TenderData) -> Double {
        guard let proposedAmount = extractNumericValue(from: proposal.proposedBudget),
              let minBudget = extractNumericValue(from: tender.minimumBudget),
              let maxBudget = extractNumericValue(from: tender.maximumBudget),
              maxBudget > minBudget else {
            return 50.0 // Neutral score if budget parsing fails
        }
        
        // Check if within range
        if proposedAmount < minBudget {
            return 20.0 // Too low, potential quality concerns
        }
        
        if proposedAmount > maxBudget {
            return 10.0 // Over budget, major concern
        }
        
        // Sweet spot calculation (70-90% of max budget gets bonus)
        let budgetRange = maxBudget - minBudget
        let proposedPosition = (proposedAmount - minBudget) / budgetRange
        
        var score: Double
        if proposedPosition >= 0.7 && proposedPosition <= 0.9 {
            score = 95.0 // Sweet spot
        } else if proposedPosition >= 0.5 && proposedPosition <= 0.95 {
            score = 85.0 // Good range
        } else if proposedPosition >= 0.3 && proposedPosition <= 0.99 {
            score = 75.0 // Acceptable range
        } else {
            score = 60.0 // Edge cases
        }
        
        return score
    }
    
    // MARK: - Reputation Scoring
    private static func calculateReputationScore(proposal: ProposalData) -> Double {
        var score: Double = 50.0 // Base score
        
        // Company name analysis (established companies might have certain patterns)
        let companyName = proposal.companyName.lowercased()
        if companyName.contains("inc") || companyName.contains("ltd") || companyName.contains("corp") || companyName.contains("llc") {
            score += 15.0 // Established business structure
        }
        
        // Experience length analysis
        let experience = proposal.experience.lowercased()
        if experience.contains("years") {
            if experience.contains("10") || experience.contains("ten") {
                score += 25.0
            } else if experience.contains("5") || experience.contains("five") {
                score += 15.0
            } else if experience.contains("3") || experience.contains("three") {
                score += 10.0
            }
        }
        
        // Portfolio/project mentions
        if experience.contains("project") || experience.contains("client") || experience.contains("delivered") {
            score += 10.0
        }
        
        return min(100.0, score)
    }
    
    // MARK: - Technical Capability Scoring
    private static func calculateTechnicalScore(proposal: ProposalData, tender: TenderData) -> Double {
        var score: Double = 50.0 // Base score
        
        let tenderCategory = tender.category.lowercased()
        let experience = proposal.experience.lowercased()
        let description = proposal.proposalDescription.lowercased()
        let combinedText = "\(experience) \(description)"
        
        // Category-specific scoring
        if tenderCategory.contains("it") || tenderCategory.contains("technology") || tenderCategory.contains("consulting") {
            let techKeywords = ["software", "development", "programming", "database", "api", "cloud", "mobile", "web", "system", "application", "technical", "coding", "algorithm", "architecture"]
            let matchCount = techKeywords.filter { combinedText.contains($0) }.count
            score += Double(matchCount * 3) // 3 points per tech keyword
        }
        
        if tenderCategory.contains("procurement") {
            let procurementKeywords = ["supplier", "vendor", "logistics", "supply", "procurement", "sourcing", "contract", "negotiation"]
            let matchCount = procurementKeywords.filter { combinedText.contains($0) }.count
            score += Double(matchCount * 3)
        }
        
        // Certification/qualification indicators
        let qualificationKeywords = ["certified", "certification", "degree", "qualification", "trained", "expert", "specialist", "professional"]
        let qualificationCount = qualificationKeywords.filter { combinedText.contains($0) }.count
        score += Double(qualificationCount * 5)
        
        return min(100.0, score)
    }
    
    // MARK: - Quality Scoring
    private static func calculateQualityScore(proposal: ProposalData) -> Double {
        var score: Double = 50.0 // Base score
        
        // Completeness check
        let requiredFields = [
            proposal.proposalTitle,
            proposal.proposedBudget,
            proposal.timeline,
            proposal.proposalDescription,
            proposal.companyName,
            proposal.contactPerson,
            proposal.email
        ]
        
        let completedFields = requiredFields.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        let completenessScore = (Double(completedFields) / Double(requiredFields.count)) * 30.0
        score += completenessScore
        
        // Description quality (length and detail)
        let descriptionLength = proposal.proposalDescription.count
        if descriptionLength > 500 {
            score += 15.0 // Detailed description
        } else if descriptionLength > 200 {
            score += 10.0 // Adequate description
        } else if descriptionLength > 50 {
            score += 5.0 // Basic description
        }
        
        // Professional language indicators
        let description = proposal.proposalDescription.lowercased()
        let professionalWords = ["deliver", "ensure", "experience", "professional", "quality", "commitment", "expertise", "solution"]
        let professionalCount = professionalWords.filter { description.contains($0) }.count
        score += Double(professionalCount * 2)
        
        return min(100.0, score)
    }
    
    // MARK: - Timeline Scoring
    private static func calculateTimelineScore(proposal: ProposalData, tender: TenderData) -> Double {
        var score: Double = 70.0 // Base score assuming reasonable timeline
        
        let timeline = proposal.timeline.lowercased()
        let tenderDeadline = tender.deadline.lowercased()
        
        // Quick timeline analysis
        if timeline.contains("week") {
            if timeline.contains("1") || timeline.contains("one") {
                score = 60.0 // Very fast, might be unrealistic
            } else if timeline.contains("2") || timeline.contains("two") {
                score = 75.0 // Fast but reasonable
            } else if timeline.contains("3") || timeline.contains("three") || timeline.contains("4") || timeline.contains("four") {
                score = 90.0 // Good timeline
            }
        } else if timeline.contains("month") {
            if timeline.contains("1") || timeline.contains("one") {
                score = 85.0 // Good timeline
            } else if timeline.contains("2") || timeline.contains("two") || timeline.contains("3") || timeline.contains("three") {
                score = 90.0 // Realistic timeline
            } else if timeline.contains("6") || timeline.contains("six") {
                score = 70.0 // Longer timeline
            }
        }
        
        // Buffer time indicators
        if timeline.contains("buffer") || timeline.contains("contingency") || timeline.contains("flexible") {
            score += 10.0
        }
        
        return min(100.0, score)
    }
    
    // MARK: - Communication Scoring
    private static func calculateCommunicationScore(proposal: ProposalData) -> Double {
        var score: Double = 70.0 // Base score
        
        // Submission timing (could be enhanced with actual submission time data)
        // For now, we'll score based on completeness and professionalism
        
        // Contact information completeness
        if !proposal.phone.isEmpty {
            score += 10.0
        }
        
        if proposal.email.contains("@") && proposal.email.contains(".") {
            score += 10.0 // Valid email format
        }
        
        // Professional communication indicators
        let description = proposal.proposalDescription
        let professionalPhrases = ["please", "thank you", "look forward", "pleased to", "happy to"]
        let professionalCount = professionalPhrases.filter { description.lowercased().contains($0) }.count
        score += Double(professionalCount * 3)
        
        return min(100.0, score)
    }
    
    // MARK: - Helper Functions
    private static func extractNumericValue(from string: String) -> Double? {
        let cleanString = string.replacingOccurrences(of: "$", with: "")
                               .replacingOccurrences(of: ",", with: "")
                               .replacingOccurrences(of: " ", with: "")
        return Double(cleanString)
    }
    
    private static func identifyStrengths(from scores: IndividualScores, proposal: ProposalData) -> [String] {
        var strengths: [String] = []
        
        if scores.budget >= 80 {
            strengths.append("Competitive pricing")
        }
        if scores.reputation >= 80 {
            strengths.append("Strong track record")
        }
        if scores.technical >= 80 {
            strengths.append("Technical expertise")
        }
        if scores.quality >= 80 {
            strengths.append("Comprehensive proposal")
        }
        if scores.timeline >= 80 {
            strengths.append("Realistic timeline")
        }
        if scores.communication >= 80 {
            strengths.append("Professional communication")
        }
        
        if strengths.isEmpty {
            strengths.append("Meets basic requirements")
        }
        
        return strengths
    }
    
    private static func identifyConcerns(from scores: IndividualScores, proposal: ProposalData, tender: TenderData) -> [String] {
        var concerns: [String] = []
        
        if scores.budget <= 40 {
            concerns.append("Budget concerns")
        }
        if scores.reputation <= 40 {
            concerns.append("Limited experience shown")
        }
        if scores.technical <= 40 {
            concerns.append("Technical capability unclear")
        }
        if scores.quality <= 40 {
            concerns.append("Incomplete proposal")
        }
        if scores.timeline <= 40 {
            concerns.append("Timeline may be unrealistic")
        }
        if scores.communication <= 40 {
            concerns.append("Communication issues")
        }
        
        return concerns
    }
    
    private static func getConfidenceLevel(score: Double, rank: Int, totalCount: Int) -> String {
        if score >= 85 {
            return "High"
        } else if score >= 70 {
            return "Medium"
        } else if score >= 55 {
            return "Low"
        } else {
            return "Very Low"
        }
    }
}
