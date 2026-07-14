import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isStartingDrivingMode: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, .primaryDarkBlue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    if isStartingDrivingMode {
                        
                        Image(systemName: "car")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                            .padding()
                        Text("Driving Mode: off")
                            .font(.title3.bold())
                        
                        
                        Button {
                            isStartingDrivingMode = !isStartingDrivingMode
                        } label: {
                            Label("", systemImage: "play.fill")
                                .labelStyle(.iconOnly)
                        }
                    }
                    ProgressView(value: 0)
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
