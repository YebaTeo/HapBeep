import Foundation
import SwiftData

@Model
class Category {
    @Attribute(.unique) var name: String
    var severity: Int
    
    @Relationship(inverse: \Sound.category)
    var sounds: [Sound]
    
    
    init(name: String, severity: Int) {
        self.name = name
        self.severity = severity
        self.sounds = []
    }
}
