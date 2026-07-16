import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isStartingDrivingMode: Bool = false
    @State private var countdown = 5
//    let timer = Timer.publish(every: 1, on: .main, in: .common).connect()
    @State var isSettingsVisible: Bool = false
    @State var isTutorialVisible: Bool = false
    
    @State private var activeSound: Sound?
    @State private var selectedIndex: Int = 0

    @Query(sort: \Sound.name) private var sounds: [Sound]
    @Query(sort: \Category.severity) private var categories: [Category]
    @State private var player = VocabularyPlayer()
    @State private var classifier = SystemAudioClassifier()
    
    @State private var currentBackgroundColor: Color = .primaryDarkBlue
    
    private var activeSoundName: String {
        if !isStartingDrivingMode || countdown >= 0 {
            return "Driving Mode: ON"
        }
        return activeSound?.displayName ?? "Listening..."
    }
    
    private var activeSoundImage: String {
        if !isStartingDrivingMode || countdown >= 0 {
            return "car.fill"
        }
        //change after db update
        return activeSound?.name ?? "car"
    }
    
    private var isDriving: Bool {
        return isStartingDrivingMode && countdown <= 0
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, currentBackgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .animation(.easeInOut(duration: 0.3), value: currentBackgroundColor)
            .ignoresSafeArea()
            
            VStack {
                if !isStartingDrivingMode {
                    LabeledImage(
                        icon: "car",
                        text: "Driving Mode: Off"
                    )
                    
//                    IconButton(icon: "play.fill") {
//                        isStartingDrivingMode = true
//                    }
//                    .padding(.top, 16)
                }
                else if countdown < 0 {
                    VStack {
                        if let sound = activeSound {
                            Image(sound.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        } else {
                            Image(systemName: "car.front.waves.left.and.right.and.up.fill")
                                .font(.system(.title))
                                .foregroundColor(.accentColor)
                        }
                        Text(activeSoundName)
                            .font(.title3.bold())
                            .padding(.top, 4)
                    }
                    
//                    IconButton(icon: "stop.fill") {
//                        isStartingDrivingMode = false
//                        countdown = 5
//                        activeSound  = nil
//                    }
//                    .padding(.top, 16)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isTutorialVisible = true
                    } label: {
                        Image(systemName: "questionmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSettingsVisible = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                IconButton(icon: isDriving ? "stop.fill" : "play.fill") {
                    if isDriving {
                        stopDrivingMode()
                    } else {
                        startDrivingMode()
                    }
                }
            }
        }
        .onChange(of: isStartingDrivingMode) { isActive in
            if isActive {
                try? classifier.start()
            } else {
                classifier.stop()
                classifier.detectedSound = nil
            }
        }
        .onChange(of: classifier.detectedSound) { detected in
            guard let detected else { return }
            let pattern = RoadPattern.pattern(for: detected)
            player.play(pattern)
            activeSound = sounds.first(where: { $0.name == detected })
            if let category = categories.first(where: { $0.severity == pattern.priority / 50 }) {
                currentBackgroundColor = category.color
            }
        }
        .onChange(of: player.isPlaying) { isPlaying in
            if !isPlaying {
                currentBackgroundColor = .primaryDarkBlue
                classifier.detectedSound = nil
                activeSound = nil
            }
        }
        .sheet(isPresented: $isSettingsVisible) {
            SettingsView()
        }
        .sheet(isPresented: $isTutorialVisible) {
            TutorialView()
        }
    }
    
    func startDrivingMode() {
        isStartingDrivingMode = true
    }
    
    func stopDrivingMode() {
        isStartingDrivingMode = false
        countdown = 5
        activeSound  = nil
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .modelContainer(DataManager.shared.container)
    }
}
