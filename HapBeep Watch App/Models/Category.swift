import Foundation
import SwiftData
import SwiftUI

@Model
class Category {
    @Attribute(.unique) var name: String
    var severity: Int
    var color: Color
    
    @Relationship(inverse: \Sound.category)
    var sounds: [Sound]
    
    
    init(name: String, severity: Int, color: Color) {
        self.name = name
        self.severity = severity
        self.color = color
        self.sounds = []
    }
}
