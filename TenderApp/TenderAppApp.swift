import SwiftUI
import SwiftData

@main
struct TenderAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TenderData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            let context = container.mainContext
            let fetchRequest = FetchDescriptor<TenderData>()
            let existingTenders = (try? context.fetch(fetchRequest)) ?? []
            
            if existingTenders.isEmpty {
                for sampleTender in TenderData.sampleData {
                    context.insert(sampleTender)
                }
                try context.save()
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
