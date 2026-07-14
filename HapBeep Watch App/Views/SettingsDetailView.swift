import SwiftUI
import SwiftData

struct SettingsDetailView: View {
    let category: Category
    
    var body: some View {
        List {
            Section("Choose Haptic") {
                Button("Haptics 1") {}
                Button("Haptics 2") {}
                Button("Haptics 3") {}
            }
            
            Section("Toggle Sounds") {
                ForEach(category.sounds) { sound in
                    Toggle(isOn: .constant(true)) {
                        Text(sound.name)
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView(category: Category(name: "Informational", severity: 0))
            .modelContainer(SampleData.shared.container)
    }
}
