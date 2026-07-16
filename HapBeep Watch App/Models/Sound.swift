import Foundation
import SwiftData

@Model
class Sound {
    @Attribute(.unique) var name: String
    var displayName: String = ""
    var icon: String = ""
    var category: Category
    var isActive: Bool = true

    init(name: String, displayName: String, icon: String, category: Category) {
        self.name = name
        self.displayName = displayName
        self.icon = icon
        self.category = category
    }
}
