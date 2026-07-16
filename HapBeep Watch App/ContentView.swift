import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    //@State private var isStartingDrivingMode: Bool = false
    @State var isSettingsVisible: Bool = false
    @State var isTutorialVisible: Bool = false
    
    @State private var activeSound: Sound?
    @State private var selectedIndex: Int = 0

    @Query(sort: \Sound.name) private var sounds: [Sound]
    @Query(sort: \Category.severity) private var categories: [Category]
    @State private var player = VocabularyPlayer()
    @State private var classifier = SystemAudioClassifier()
    
    @State private var currentBackgroundColor: Color = .primaryDarkBlue
    
    @State private var countdown = 5
    @State private var systemState: SystemState = .drivingOff
    @State private var progress: Double = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let totalCountdown = 5
    
    private var activeSoundName: String {
        if systemState == .drivingOff {
            return "Driving Mode: ON"
        }
        
        return activeSound?.displayName ?? "Listening..."
    }
    
    private var activeSoundImage: String {
        if systemState == .drivingOff {
            return "car.fill"
        }
        //change after db update
        return activeSound?.name ?? "car"
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
                if systemState == .drivingOff {
                    LabeledImage(
                        icon: "car",
                        text: "Driving Mode: Off"
                    )
                } else if systemState == .starting {
                    CircularProgressView(countdown: $countdown, progress: $progress)
                } else {
                    VStack {
                        if let sound = activeSound {
                            Image(systemName: sound.icon)
                                .font(.largeTitle)
                                .foregroundStyle(sound.category.color)
                        } else {
                            Image(systemName: "car.front.waves.left.and.right.and.up.fill")
                                .font(.system(.title))
                                .foregroundColor(.accentColor)
                        }
                        Text(activeSoundName)
                            .font(.title3.bold())
                            .padding(.top, 4)
                    }
                }
            }
        }
        .toolbar {
            if systemState == .starting {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //isStartingDrivingMode = false
                        stopDrivingMode()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if systemState == .drivingOff {
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
            
            if systemState != .starting {
                ToolbarItem(placement: .bottomBar) {
                    if systemState == .drivingOn {
                        IconButton(icon: "stop.fill") {
                            stopDrivingMode()
                        }
                    } else {
                        IconButton(icon: "play.fill") {
                            startDrivingMode()
                        }
                    }
                }
            }
        }
        .onChange(of: systemState) { state in
            if state == .drivingOn {
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
        .onReceive(timer) { _ in
            guard systemState == .starting else {
                return
            }
            
            if countdown < 1 {
                systemState = .drivingOn
                return
            }
            
            countdown -= 1
            if countdown <= totalCountdown {
                progress = Double(totalCountdown - countdown) / Double(totalCountdown)
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
        systemState = .starting
    }
    
    func stopDrivingMode() {
        countdown = 5
        activeSound  = nil
        
        systemState = .drivingOff
        progress = 0.0
    }
}

enum SystemState {
    case drivingOn
    case drivingOff
    case starting
}

#Preview {
    NavigationStack {
        ContentView()
            .modelContainer(DataManager.shared.container)
    }
}
