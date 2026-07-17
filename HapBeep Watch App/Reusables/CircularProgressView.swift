import SwiftUI

struct CircularProgressView: View {
    @Binding var countdown: Int
    @Binding var progress: CGFloat
    
    private var currentVisualProgress: CGFloat {
        if countdown >= 3 {
            let maxReadyTime: CGFloat = 5.0
            let totalReadyDuration: CGFloat = maxReadyTime - 3.0
            let remainingReadyTime = CGFloat(countdown) - 3.0
            
            return max(0, min(1, remainingReadyTime / totalReadyDuration))
        } else {
            return progress
        }
    }

    var body: some View {
        ZStack {

            Circle()
                .trim(from: 0, to: currentVisualProgress)
                .stroke(
                    .teal,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: currentVisualProgress)

                Text(countdown >= 3 ? "Ready" : "\(countdown + 1)")
                    .font(.title2.bold())
                    .foregroundStyle(.teal)
        }
    }
}

#Preview {
    CircularProgressView(countdown: .constant(3), progress: .constant(0.0))
}
