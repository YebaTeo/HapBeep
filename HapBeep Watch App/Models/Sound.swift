import Foundation
import SwiftData

@Model
class Sound {
    @Attribute(.unique) var name: String
    var category: Category
    var isActive: Bool = true
    
    init(name: String, category: Category) {
        self.name = name
        self.category = category
    }
}
