import SwiftUI
import SwiftData

struct CautionAlertInfoView: View {
    @Query(filter: #Predicate<Category> { category in
        category.name == "Caution"
    })
    private var categories: [Category]

    private var category: Category? {
        categories.first
    }
    
    var body: some View {
        VStack {
            VStack{
                Text(category?.name ?? "Caution")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                Text("Be alert and prepare to react")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 10)
            
            HStack (spacing: 12) {
                if let category = category {
                    ForEach(category.sounds) { sound in
                        Image(systemName: sound.icon)
                            .font(.title2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CautionAlertInfoView()
    }
}
