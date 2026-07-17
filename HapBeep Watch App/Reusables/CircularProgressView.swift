import SwiftUI

struct CircularProgressView: View {
    @Binding var countdown: Int
    let maxCountdown: CGFloat
        
    private var currentVisualProgress: CGFloat {
        if countdown >= 3 {
            return 1
            
            //let totalReadyDuration: CGFloat = maxCountdown - 3.0
            //let remainingReadyTime = CGFloat(countdown) - 3.0
            //return max(0, min(1, remainingReadyTime / totalReadyDuration))
        } else {
            let diff = Double(maxCountdown) - Double(countdown)
            return 1 - diff / maxCountdown
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
                .animation(.smooth(duration: 0.75), value: currentVisualProgress)

                Text(countdown >= 3 ? "Ready" : "\(countdown + 1)")
                    .font(.title.bold())
                    .foregroundStyle(.teal)
                    .contentTransition(.numericText())
                    .animation(.bouncy, value: countdown)
            
            Circle()
                .stroke(
                    .teal.opacity(0.3),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
        }
    }
}

#Preview {
    @Previewable @State var countdown: Int = 5
    let maxCountdown: CGFloat = 4.0
    
    CircularProgressView(
        countdown: $countdown,
        maxCountdown: maxCountdown
    )
}
