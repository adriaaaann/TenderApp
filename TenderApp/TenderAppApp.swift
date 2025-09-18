import SwiftUI
import SwiftData

@main
struct TenderAppApp: App {
    @State private var authService = AuthenticationService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TenderData.self,
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Add sample tenders for testing
            let context = container.mainContext
            
            // Check if tenders already exist
            let fetchRequest = FetchDescriptor<TenderData>()
            let existingTenders = try? context.fetch(fetchRequest)
            
            if existingTenders?.isEmpty ?? true {
                // Create sample tenders
                let sampleTenders = [
                    TenderData(
                        title: "Office Building Renovation",
                        category: "Construction",
                        location: "New York, NY",
                        deadline: "30/12/2025",
                        minimumBudget: "250000",
                        maximumBudget: "500000",
                        projectDescription: "Complete renovation of a 5-story office building including electrical, plumbing, and interior design work.",
                        requirements: "Minimum 5 years experience in commercial building renovation. Licensed contractors only.",
                        status: .active,
                        applicationsCount: 0
                    ),
                    TenderData(
                        title: "Mobile App Development",
                        category: "IT Services",
                        location: "San Francisco, CA",
                        deadline: "15/01/2026",
                        minimumBudget: "75000",
                        maximumBudget: "150000",
                        projectDescription: "Develop a cross-platform mobile application for e-commerce with payment integration and user management.",
                        requirements: "Experience with React Native or Flutter. Portfolio of published mobile apps required.",
                        status: .active,
                        applicationsCount: 0
                    ),
                    TenderData(
                        title: "Hospital Equipment Supply",
                        category: "Healthcare",
                        location: "Chicago, IL",
                        deadline: "28/02/2026",
                        minimumBudget: "1000000",
                        maximumBudget: "2000000",
                        projectDescription: "Supply and installation of medical equipment for a new hospital wing including MRI machines, X-ray equipment, and patient monitors.",
                        requirements: "FDA approved medical equipment supplier. Installation and maintenance support required.",
                        status: .active,
                        applicationsCount: 0
                    )
                ]
                
                for tender in sampleTenders {
                    context.insert(tender)
                }
                
                try? context.save()
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .onAppear {
                    authService.setModelContext(sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
