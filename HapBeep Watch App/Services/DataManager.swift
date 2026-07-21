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
    
    func resetData() {
        deleteData()
        insertSampleData()
    }
    
    private func insertSampleData() {
        let categoryDescriptor = FetchDescriptor<Category>()
        let soundDescriptor = FetchDescriptor<Sound>()
        let existingSounds = (try? context.fetch(soundDescriptor)) ?? []
        let existingCount = (try? context.fetchCount(categoryDescriptor)) ?? 0

        // ✅ Verify that both targeted parameters exist AND are explicitly assigned to Critical (severity: 2)
        let hasCriticalCrash = existingSounds.contains { $0.name == "car_crash" && $0.category.severity == 2 }
        let hasCriticalMachine = existingSounds.contains { $0.name == "machine_faulty" && $0.category.severity == 2 }

        if existingCount > 0 {
            let firstSound = existingSounds.first
            // Wipes the cache if parameters are missing or mapped to Caution by mistake
            if firstSound?.displayName.isEmpty == true || !hasCriticalCrash || !hasCriticalMachine {
                print("🔄 Structural change found! Resetting SwiftData storage context...")
                existingSounds.forEach { context.delete($0) }
                (try? context.fetch(categoryDescriptor))?.forEach { context.delete($0) }
                try? context.save()
            } else {
                return // Cache is updated
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
        let soundData: [(name: String, displayName: String, icon: String, cta: String, category: Category)] = [
            ("reverse_beeps",     "Dashboard Alert",     "powermeter", "Check the system dashboard", informational),
            ("knock",             "Knocking",           "car.window.right.exclamationmark",    "Check your windows",   informational),
            
            ("car_horn",          "Car Horn",           "horn.blast",    "Check your mirrors",    caution),
            ("traffic_noise",     "Approaching Vehicle","car.2.fill",    "Check your mirrors",     caution),
            ("vehicle_skidding",  "Tire Screeching",    "car.rear.and.tire.marks", "Check your mirrors", caution),
            ("bump", "Bump", "car.rear.road.lane.distance.3", "Pull over and inspect your vehicle",  caution),
            
            ("emergency_vehicle", "Sirens",             "light.beacon.max.fill", "Check your mirrors and pull over to give way", critical),
            ("machine_faulty",    "Faulty Machine",     "wrench.and.screwdriver.fill", "Pull over and inspect your vehicle", critical),
            ("major_crash", "Crash", "car.side.rear.and.collision.and.car.side.front", "Pull over and inspect your vehicle", critical)
        ]
        
        for data in soundData {
            let sound = Sound(name: data.name, displayName: data.displayName, icon: data.icon, category: data.category, cta: data.cta)
            context.insert(sound)
        }
        
        do {
            try context.save()
            print("Successfully updated model instances inside database layer context records.")
        } catch {
            print("Failed to insert sample data: \(error)")
        }
    }
    
    private func deleteData() {
        do {
            try context.delete(model: Category.self)
        } catch {
            print("Failed to delete all sounds: \(error)")
        }
    }
}
