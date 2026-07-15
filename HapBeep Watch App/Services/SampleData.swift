import Foundation
import SwiftData
import SwiftUI


class SampleData {
    static let shared = SampleData()
    let container: ModelContainer
    let context: ModelContext
    
    private init() {
        let schema = Schema([Sound.self, Category.self])
        
        let configurations = ModelConfiguration(
            isStoredInMemoryOnly: true,
            allowsSave: true
        )
        
        do {
            self.container = try ModelContainer(
                for: schema,
                configurations: configurations
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        
        self.context = container.mainContext
        
        insertSampleData()
    }
    
    private func insertSampleData() {
        // Inserting categories
        let informational = Category(name: "Information", severity: 0, color: .teal, hapticPattern: .information)
        let caution = Category(name: "Caution", severity: 1, color: .orange, hapticPattern: .caution)
        let critical = Category(name: "Critical", severity: 2, color: .red, hapticPattern: .critical)
        
        context.insert(informational)
        context.insert(caution)
        context.insert(critical)
        
        // Inserting informational sounds
        let informationalSounds = [
            "Parking Sensor",
            "Knocking",
        ]
        
        for sound in informationalSounds {
            let sound = Sound(name: sound, category: informational)
            context.insert(sound)
        }
        
        // Inserting caution sounds
        let cautionSounds: [String] = [
            "Horns",
            "Approaching Vehicle",
        ]
        
        for sound in cautionSounds {
            let sound = Sound(name: sound, category: caution)
            context.insert(sound)
        }
        
        // Inserting critical sounds
        let criticalSounds: [String] = [
            "Sirens",
            "Nearby Crash",
            "Flat Tire",
            "Tire Screeching",
            "Metal Rattling"
        ]
        
        for sound in criticalSounds {
            let sound = Sound(name: sound, category: critical)
            context.insert(sound)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to insert sample data: \(error)")
        }
    }
}
