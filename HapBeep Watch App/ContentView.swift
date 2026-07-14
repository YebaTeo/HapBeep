import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isStartingDrivingMode: Bool = false
    @State private var countdown = 5
//    let timer = Timer.publish(every: 1, on: .main, in: .common).connect()
    @State var isSettingsVisible: Bool = false
    @State private var activeSound: Sound?
    @State private var selectedIndex: Int = 0

    @Query(sort: \Sound.name) private var sounds: [Sound]
    @State private var player = VocabularyPlayer()
    
    private var backgroundColor: Color {
        if !isStartingDrivingMode || countdown >= 0{
            return .primaryDarkBlue
        }
        return activeSound?.category.color ?? .primaryDarkBlue
    }
    
    private var activeSoundName: String {
        if !isStartingDrivingMode || countdown >= 0{
            return "Driving Mode: ON"
        }
        return activeSound?.name ?? "Driving Mode: ON"
    }
    
    private var activeSoundImage: String {
        if !isStartingDrivingMode || countdown >= 0 {
            return "car.fill"
        }
        //change after db update
        return activeSound?.name ?? "car"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, backgroundColor], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    if !isStartingDrivingMode {
                        LabeledImage(
                            icon: "car",
                            text: "Driving Mode: Off"
                        )
                        
                        IconButton(icon: "play.fill") {
                            isStartingDrivingMode = true
                        }
                        .padding(.top, 16)
                    }
                    else if countdown < 0 {
                        LabeledImage(
                            icon: "car.front.waves.left.and.right.and.up.fill",
                            text: activeSoundName
                        )
                        
                        IconButton(icon: "stop.fill") {
                            isStartingDrivingMode = false
                            countdown = 5
                        }
                        .padding(.top, 16)
                    } else {
                        CircularProgressView(countdown: $countdown)
                    }
                }
            }
            .toolbar {
                if countdown > -1 && isStartingDrivingMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isStartingDrivingMode = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.red)
                        }
                    }
                } else if !isStartingDrivingMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isSettingsVisible = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        guard !sounds.isEmpty else { return }

                        activeSound = sounds[selectedIndex]

                        print(activeSound?.name ?? "nil")

                        selectedIndex = (selectedIndex + 1) % sounds.count
                        
                        player.play(activeSound?.category.hapticPattern ?? .caution)

                    } label: {
                        Image(systemName: "play")
                            .resizable()
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .sheet(isPresented: $isSettingsVisible) {
                SettingsView()
            }
        }

    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.container)
}
