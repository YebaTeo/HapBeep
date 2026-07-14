import SwiftUI
import SwiftData

struct ContentView: View {
    @State var isSettingsVisible: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to HapBeep App!")
                    .multilineTextAlignment(.center)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSettingsVisible = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $isSettingsVisible) {
                SettingsView()
            }
        }
    }
}

// Onboarding Screen
// Widget
// HIG Watch

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.container)
}
