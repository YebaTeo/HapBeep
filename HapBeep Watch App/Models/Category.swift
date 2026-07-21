import Foundation
import SwiftData
import SwiftUI

@Model
class Category {
    @Attribute(.unique) var name: String
    var severity: Int
    var colorName: String
    var hapticPattern: RoadPattern

    @Relationship(deleteRule: .cascade, inverse: \Sound.category)
    var sounds: [Sound]

    var color: Color {
        switch colorName {
        case "teal": return .teal
        case "orange": return .orange
        case "red": return .red
        default: return .teal
        }
    }

    init(name: String, severity: Int, color: Color, hapticPattern: RoadPattern = .information) {
        self.name = name
        self.severity = severity
        self.hapticPattern = hapticPattern
        self.sounds = []
        self.colorName = Category.colorName(for: color)
    }

    private static func colorName(for color: Color) -> String {
        if color == .red    { return "red" }
        if color == .orange { return "orange" }
        if color == .teal { return "teal" }
        return "teal"
    }
}
