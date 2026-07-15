import SwiftUI

struct GradientBackground<Content: View>: View {
    let color: Color
    @ViewBuilder let content: Content
    
    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, color.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

#Preview {
    GradientBackground(color: .red) {
        Text("Hello")
    }
}
