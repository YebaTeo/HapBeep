import SwiftUI
import SwiftData

@main
struct HapBeep_Watch_AppApp: App {
    @AppStorage("hasCompletedOnBoarding")
    private var hasCompleteOnBoarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompleteOnBoarding {
                    NavigationStack {
                        ContentView()
                    }
                } else {
                    NavigationStack {
                        OnBoardingWelcomeView()
                    }
                }
            }
            .modelContainer(DataManager.shared.container)
        }
    }
}
