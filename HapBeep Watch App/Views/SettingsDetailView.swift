import SwiftUI
import SwiftData

struct SettingsDetailView: View {
    @Bindable var category: Category
    @State private var player = VocabularyPlayer()

    private var availablePatterns: [RoadPattern] {
        let targetPriority: Int
        switch category.severity {
        case 0:  targetPriority = 0
        case 1:  targetPriority = 50
        default: targetPriority = 100
        }
        return RoadPattern.allCases.filter { $0.priority == targetPriority }
    }

    var body: some View {
        List {
            Section("Haptic Pattern") {
                ForEach(availablePatterns) { pattern in
                    Button {
                        category.hapticPattern = pattern
                        player.play(pattern)
                    } label: {
                        HStack {
                            Text(pattern.rawValue)
                            Spacer()
                            if category.hapticPattern == pattern {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }

            Section("Sounds") {
                ForEach(category.sounds) { sound in
                    @Bindable var sound = sound
                    Toggle(sound.displayName, isOn: $sound.isActive)
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView(category: Category(name: "Information", severity: 0, color: .blue, hapticPattern: .information))
            .modelContainer(DataManager.shared.container)
    }
}
