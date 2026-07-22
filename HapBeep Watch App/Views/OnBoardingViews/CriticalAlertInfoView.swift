import SwiftUI
import SwiftData

struct CriticalAlertInfoView: View {
    @Query(filter: #Predicate<Category> { category in
        category.name == "Critical"
    })
    private var criticalCategories: [Category]

    private var criticalCategory: Category? {
        criticalCategories.first
    }
    
    var body: some View {
        VStack{
            VStack{
                Text(criticalCategory?.name ?? "Critical")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                Text("Immediate action may be required")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 10)
            
            HStack (spacing: 12) {
                if let category = criticalCategory {
                    ForEach(category.sounds) { sound in
                        Image(systemName: sound.icon)
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CriticalAlertInfoView()
    }
    .modelContainer(DataManager.shared.container)
}
