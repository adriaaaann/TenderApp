import SwiftUI
import SwiftData

@main
struct TenderAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authService = AuthenticationService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TenderData.self,
            User.self,
            ProposalData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            print("Model container creation failed, attempting to create new container: \(error)")
            
            let tempConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            do {
                let newContainer = try ModelContainer(for: schema, configurations: [tempConfiguration])
                return newContainer
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .onAppear {
                    authService.setModelContext(sharedModelContainer.mainContext)
                    NotificationService.shared.requestPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
