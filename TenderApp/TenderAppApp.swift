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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
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
                    NotificationService.shared.requestPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
