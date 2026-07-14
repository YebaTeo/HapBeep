import SwiftUI
import SwiftData

struct SettingsDetailView: View {
    let category: Category
    
    var body: some View {
        List {
            Section("Haptic Patterns") {
                Button("Haptics 1") {}
                Button("Haptics 2") {}
                Button("Haptics 3") {}
            }
            
            Section("Sounds") {
                ForEach(category.sounds) { sound in
                    @Bindable var sound = sound
                    
                    Toggle(sound.name, isOn: $sound.isActive)
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
