import SwiftUI
import SwiftData
import AVFoundation

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
            .task {
                if AVAudioApplication.shared.recordPermission == .undetermined {
                    let granted = await AVAudioApplication.requestRecordPermission()
                    print("[PERMISSION]: Microphone permission \(granted ? "granted" : "denied")")
                }

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
