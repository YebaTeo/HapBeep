import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(sort: \Category.severity) var categories: [Category]
    @State var selectedCategory: Category? = nil
    
    var body: some View {
        VStack {
            List {
                ForEach(categories) { category in
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
        .navigationTitle("Alert Settings")
        .navigationBarTitleDisplayMode( .inline)
        .sheet(item: $selectedCategory) { category in
            SettingsDetailView(category: category)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(DataManager.shared.container)
    }
}
