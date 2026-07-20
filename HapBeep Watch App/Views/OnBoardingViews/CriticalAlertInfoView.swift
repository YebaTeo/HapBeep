import SwiftUI
import SwiftData

struct CriticalAlertInfoView: View {
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
                Image(systemName: "light.beacon.max.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CriticalAlertInfoView()
    }
}
