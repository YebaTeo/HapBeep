import Foundation
import SwiftData
import SwiftUI

@Model
class Category {
    @Attribute(.unique) var name: String
    var severity: Int
    var colorName: String
    var hapticPattern: RoadPattern

    @Relationship(inverse: \Sound.category)
    var sounds: [Sound]

    var color: Color {
        switch colorName {
        case "red":    return .red
        case "yellow": return .yellow
        case "orange": return .orange
        case "green":  return .green
        case "purple": return .purple
        default:       return .blue
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
        if color == .yellow { return "yellow" }
        if color == .orange { return "orange" }
        if color == .green  { return "green" }
        if color == .purple { return "purple" }
        return "blue"
    }
}
