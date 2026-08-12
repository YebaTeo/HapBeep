import SwiftUI
import SwiftData

@main
struct HapBeep_Watch_AppApp: App {
    @AppStorage("hasCompletedOnBoarding")
    private var hasCompleteOnBoarding: Bool = false
    
    let notificationManager = NotificationManager.shared
    
    init() {
        checkForVersionUpdate()
    }
    
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
            .onAppear {
                notificationManager.requestAuthorization()
            }
        }
    }
    
    private func checkForVersionUpdate() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let lastVersion = UserDefaults.standard.string(forKey: "lastLaunchedVersion")

        if lastVersion != currentVersion {
            onVersionUpdate(from: lastVersion, to: currentVersion)
            UserDefaults.standard.set(currentVersion, forKey: "lastLaunchedVersion")
        }
    }
    
    private func onVersionUpdate(from oldVersion: String?, to newVersion: String) {
       if oldVersion == nil {
           print("Fresh install, version \(newVersion)")
       } else {
           print("Updated from \(oldVersion!) to \(newVersion)")
       }
           
        DataManager.shared.resetData()
    }
}
