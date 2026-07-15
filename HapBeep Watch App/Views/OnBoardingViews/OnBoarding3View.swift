import SwiftUI

struct OnBoarding3View: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Feels what matters")
                .font(.subheadline.bold())
            
            List {
                ColoredList(color: .teal) {
                    OnBoarding3ListItem(
                        title: "Information",
                        subtitle: "For your awareness"
                    )
                }
                
                ColoredList(color: .orange) {
                    OnBoarding3ListItem(
                        title: "Caution",
                        subtitle: "Check when safe"
                    )
                }
                
                ColoredList(color: .red) {
                    OnBoarding3ListItem(
                        title: "Critical",
                        subtitle: "Requires immediate action"
                    )
                }
            }
        }
    }
}

struct OnBoarding3ListItem: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline.bold())
            Text(subtitle)
                .font(.caption2)
        }
    }
}

#Preview {
    OnBoarding3View()
}
