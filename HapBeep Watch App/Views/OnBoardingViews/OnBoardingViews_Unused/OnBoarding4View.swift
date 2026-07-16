import SwiftUI
import SwiftData

struct OnBoarding4View: View {
    @Query(sort: \Category.severity) var categories: [Category]
    @State var selectedCategory: Category?
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Customize your alerts")
                .font(.subheadline.bold())
            
            List {
                ForEach(categories) { category in
                    ColoredList(color: category.color) {
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack {
                                Text(category.name)
                                
                                Spacer()
                                
                                HStack {
                                    Text(category.hapticPattern.rawValue)
                                        .font(.system(.caption))
                                    Image(systemName: "chevron.right")
                                        .font(.system(.caption2))
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedCategory) { category in
            SettingsDetailView(category: category)
        }
    }
}

#Preview {
    OnBoarding4View()
        .modelContainer(DataManager.shared.container)
}
