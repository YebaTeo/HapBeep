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
        let existingSounds = (try? context.fetch(soundDescriptor)) ?? []
        let existingCount = (try? context.fetchCount(categoryDescriptor)) ?? 0

        // Check if the store is missing the newly added "car_crash" type
        let containsCarCrash = existingSounds.contains { $0.name == "car_crash" }

        if existingCount > 0 {
            let firstSound = existingSounds.first
            // If displayName is empty or we are missing the car_crash entry — wipe it for a fresh build
            if firstSound?.displayName.isEmpty == true || !containsCarCrash {
                print("🔄 Updating database records to register missing sound entries...")
                existingSounds.forEach { context.delete($0) }
                (try? context.fetch(categoryDescriptor))?.forEach { context.delete($0) }
                try? context.save()
            } else {
                return // Database is already current
            }
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
            ("reverse_beeps",     "Parking Sensor",     "car.top.radiowaves.rear", informational),
            ("knock",             "Knocking",           "car.window.right.exclamationmark",       informational),
            ("car_horn",          "Car Horn",           "horn.blast.fill",        caution),
            ("traffic_noise",     "Approaching Vehicle","car.2.fill",         caution),
            ("vehicle_skidding",  "Tire Screeching",    "car.rear.and.tire.marks", caution),
            ("emergency_vehicle", "Sirens",             "light.beacon.max.fill", critical),
            // ✅ REGISTERING CAR CRASH IN CAUTION CATEGORY
            ("car_crash",         "Car Crash Detected", "exclamationmark.triangle.fill",  caution)
        ]
        
        for data in soundData {
            let sound = Sound(name: data.name, displayName: data.displayName, icon: data.icon, category: data.category)
            context.insert(sound)
        }
        
        do {
            try context.save()
            print("🚀 Successfully populated database with all standard event identifiers.")
        } catch {
            print("Failed to insert sample data: \(error)")
        }
    }
}
