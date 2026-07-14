import Foundation
import SwiftData

@Model
class Category {
    @Attribute(.unique) var name: String
    var sounds: [Sound]
    var severity: Int
    
    init(name: String, severity: Int) {
        self.name = name
        self.sounds = []
        self.severity = severity
    }
}
