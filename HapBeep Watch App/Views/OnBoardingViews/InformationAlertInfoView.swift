import SwiftUI
import SwiftData

struct InformationAlertInfoView: View {
    @Query(filter: #Predicate<Category> { category in
        category.name == "Information"
    })
    private var categories: [Category]

    private var category: Category? {
        categories.first
    }
    
    @State private var tapCount: Int = 0
    private var dataManager = DataManager.shared
    
    var body: some View {
        VStack {
            VStack{
                Text(category?.name ?? "Information")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.teal)
                
                Text("General sounds that may be useful to notice")
                    .font(.caption)
                    .foregroundStyle(.teal)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 16)
            
            HStack (spacing: 12) {
                if let category = category {
                    ForEach(category.sounds) { sound in
                        Button {
                            tapCount += 1
                            
                            if tapCount >= 12 {
                                dataManager.resetData()
                                tapCount = 0
                            }
                        } label: {
                            Image(systemName: sound.icon)
                                .font(.title2)
                                .foregroundStyle(.teal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InformationAlertInfoView()
    }
}

