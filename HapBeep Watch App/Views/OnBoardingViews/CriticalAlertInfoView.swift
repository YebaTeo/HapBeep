import SwiftUI
import SwiftData

struct CriticalAlertInfoView: View {
    var body: some View {
        ScrollView {
            VStack{
                VStack{
                    Spacer()
                    Text("Critical")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                    Text("Pull over immediately and inspect your vehicle")
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
        .padding(.bottom, 16)
//        .toolbar {
//            ToolbarItem(placement: .bottomBar) {
//                NavigationLink("Continue") {
//                    GradientBackground(color: .orange) {
//                        CautionAlertInfoView()
//                    }
//                }
//                .buttonStyle(.glass)
//            }
//        }
    }
}

#Preview {
    NavigationStack {
        CriticalAlertInfoView()
    }
}
