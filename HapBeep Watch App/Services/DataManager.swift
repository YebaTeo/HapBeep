import Foundation
import SwiftData
import SwiftUI


class DataManager {
    static let shared = DataManager()
    let container: ModelContainer
    let context: ModelContext
    
    private init() {
        let schema = Schema([Sound.self, Category.self])
        
        let configurations = ModelConfiguration(
            isStoredInMemoryOnly: false,
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
        let categoryDescriptor = FetchDescriptor<Category>()
        let soundDescriptor = FetchDescriptor<Sound>()
        let existingCount = (try? context.fetchCount(categoryDescriptor)) ?? 0

        if existingCount > 0 {
            let firstSound = try? context.fetch(soundDescriptor).first
            // If displayName is empty the store has old pre-migration data — wipe it
            guard firstSound?.displayName.isEmpty == true else { return }
            (try? context.fetch(soundDescriptor))?.forEach { context.delete($0) }
            (try? context.fetch(categoryDescriptor))?.forEach { context.delete($0) }
            try? context.save()
        }
        
        // Inserting categories
        let informational = Category(name: "Information", severity: 0, color: .teal, hapticPattern: .information)
        let caution = Category(name: "Caution", severity: 1, color: .orange, hapticPattern: .caution)
        let critical = Category(name: "Critical", severity: 2, color: .red, hapticPattern: .critical)
        
        context.insert(informational)
        context.insert(caution)
        context.insert(critical)
        
        // (name: internal identifier, displayName: shown in UI, icon: asset name)
        let soundData: [(name: String, displayName: String, icon: String, category: Category)] = [
            ("reverse_beeps",     "Parking Sensor",     "IconDashboardSound", informational),
            ("knock",             "Knocking",           "IconKnocking",       informational),
            ("car_horn",          "Car Horn",           "IconHonkCar",        caution),
            ("traffic_noise",     "Approaching Vehicle","IconEngine",         caution),
            ("vehicle_skidding",  "Tire Screeching",    "IconTireScreeching", caution),
            ("emergency_vehicle", "Sirens",             "IconSirens",         critical),
        ]
        
        for data in soundData {
            let sound = Sound(name: data.name, displayName: data.displayName, icon: data.icon, category: data.category)
            context.insert(sound)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to insert sample data: \(error)")
        }
    }
}
