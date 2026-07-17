import SwiftUI
import Combine

struct CircularProgressView: View {
    @Binding var countdown: Int
    @Binding var progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white, lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    .primaryDarkBlue,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            ZStack {
                Text(countdown > 3 ? "Ready" : "\(countdown + 1)")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(countdown > 3 ? "Ready" : "\(countdown + 1)")
                    .font(.title2.bold())
                    .foregroundStyle(.primaryDarkBlue)
                    .opacity(progress)
            }
        }
    }
}

#Preview {
    CircularProgressView(countdown: .constant(5), progress: .constant(0.0))
}
