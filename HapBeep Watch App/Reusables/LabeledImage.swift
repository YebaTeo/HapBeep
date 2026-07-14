import SwiftUI

struct LabeledImage: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(.title))
                .foregroundColor(.accentColor)
            
            Text(text)
                .font(.title3.bold())
                .padding(.top, 4)
        }
    }
}

#Preview {
    LabeledImage(
        icon: "car",
        text: "Driving Mode: Off"
    )
}

