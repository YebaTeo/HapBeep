import SwiftUI
import SwiftData

struct CriticalAlertInfoView: View {    
    private var icons: [String] = [
        "light.beacon.max.fill",
        "exclamationmark.triangle.fill",
        "wrench.and.screwdriver.fill"
    ]
    
    var body: some View {
        VStack{
            VStack{
                Text("Critical")
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
                ForEach(icons, id: \.description) { icon in
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.red)
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
