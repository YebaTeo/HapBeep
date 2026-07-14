import SwiftUI
import Combine

struct CircularProgressView: View {
    @Binding var countdown: Int
    @State private var progress = 0.0

    let totalCountdown = 3

    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

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
                Text(countdown > 3 ? "Ready" : "\(countdown)")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(countdown > 3 ? "Ready" : "\(countdown)")
                    .font(.title2.bold())
                    .foregroundStyle(.primaryDarkBlue)
                    .opacity(progress)
            }
        }
        .onReceive(timer) { _ in
            guard countdown >= -1 else { return }

            countdown -= 1

            if countdown <= totalCountdown {
                progress = Double(totalCountdown - countdown) / Double(totalCountdown)
            }
        }
    }
}

#Preview {
    CircularProgressView(countdown: .constant(5))
}
