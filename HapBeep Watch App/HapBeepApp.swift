import SwiftUI
import SwiftData

@main
struct HapBeep_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(SampleData.shared.container)
        }
    }
}
