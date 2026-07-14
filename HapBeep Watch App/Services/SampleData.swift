import Foundation
import SwiftData


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
        for category in Category.mockData {
            context.insert(category)
        }
        
        for sound in Sound.mockData {
            context.insert(sound)
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to insert sample data: \(error)")
        }
    }
}

extension Sound {
    static let mockData: [Sound] = [
        .init(name: "Parking Sensor", category: Category.mockData[0]),
        .init(name: "Knocking", category: Category.mockData[0]),
        .init(name: "Horns", category: Category.mockData[1]),
        .init(name: "Approaching Vehicle", category: Category.mockData[1]),
        .init(name: "Sirens", category: Category.mockData[2]),
        .init(name: "Nearby Crash", category: Category.mockData[2]),
        .init(name: "Flat Tire", category: Category.mockData[2]),
        .init(name: "Tire Screeching", category: Category.mockData[2]),
        .init(name: "Metal Rattling", category: Category.mockData[2]),
    ]
}

extension Category {
    static let mockData: [Category] = [
        .init(name: "Informational", severity: 0),
        .init(name: "Caution", severity: 1),
        .init(name: "Critical", severity: 2),
    ]
}
