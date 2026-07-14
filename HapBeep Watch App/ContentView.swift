import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isStartingDrivingMode: Bool = false
    @State private var countdown = 5
//    let timer = Timer.publish(every: 1, on: .main, in: .common).connect()
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, .primaryDarkBlue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    if !isStartingDrivingMode {
                        
                        Image(systemName: "car")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                            .padding()
                        Text("Driving Mode: OFF")
                            .font(.title3.bold())
                        
                        
                        Button {
                            isStartingDrivingMode = !isStartingDrivingMode
                        } label: {
                            Label("car.front.waves.left.and.right.and.up.fill", systemImage: "play.fill")
                                .labelStyle(.iconOnly)
                        }
                    }
                    else if countdown < 0 {
                        Image(systemName: "car")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                            .padding()
                        Text("Driving Mode: ON")
                            .font(.title3.bold())
                        
                        
                        Button {
                            isStartingDrivingMode = !isStartingDrivingMode
                            countdown = 5
                        } label: {
                            Label("", systemImage: "stop.fill")
                                .labelStyle(.iconOnly)
                        }
                    } else {
                        CircularProgressView(countdown: $countdown)
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                
            }
        }

    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.container)
}
