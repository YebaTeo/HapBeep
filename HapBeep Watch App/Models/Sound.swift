import Foundation
import SwiftData

@Model
class Sound {
    @Attribute(.unique) var name: String
    var displayName: String = ""
    var icon: String = ""
    var category: Category
    var isActive: Bool = true
    var cta: String = ""

    init(name: String, displayName: String, icon: String, category: Category, cta: String) {
        self.name = name
        self.displayName = displayName
        self.icon = icon
        self.category = category
        self.cta = cta
    }
}
