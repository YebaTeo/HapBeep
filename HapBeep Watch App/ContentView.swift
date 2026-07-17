import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
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
    @State private var progress: CGFloat = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let totalCountdown = 5
    
    let notificationManager = NotificationManager.shared
    
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
            
            if systemState != .starting && activeSound == nil {
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
            
            ToolbarItem(placement: .bottomBar) {
                IconButton(icon: "sun.max") {
                    notificationManager.createNotification(
                        title: "Hello, world!",
                        body: "Lorem ipsum dolor sit amet"
                    )
                }
            }
        }
        .onChange(of: systemState) { _, state in
            if state == .drivingOn {
                try? classifier.start()
            } else {
                classifier.stop()
                classifier.detectedSound = nil
                activeSound = nil
            }
        }
        .onChange(of: classifier.detectedSound) { _, detected in
            guard let detected else { return }
            print("📱 UI OnChange Triggered via Classifier: \(detected)")
            handleDetectedSound(detected)
        }
        .onChange(of: player.isPlaying) { _, isPlaying in
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
                let diff: Int = totalCountdown - countdown
                progress = Double(diff) / Double(totalCountdown)
            }
        }
        .sheet(isPresented: $isSettingsVisible) {
            SettingsView()
        }
        .sheet(isPresented: $isTutorialVisible) {
            TutorialView()
        }
    }
    
    private func handleDetectedSound(_ detected: String) {
        print("🔍 UI Handle Executing -> Querying SwiftData for match: \(detected)")
        let pattern = RoadPattern.pattern(for: detected)
        player.play(pattern)
        
        let matchedSound: Sound? = sounds.first { $0.name == detected }
        
        if let matched = matchedSound {
            print("🎉 Match Found! Updating UI State to Display Name: \(matched.displayName)")
            activeSound = matched
            
            // ✅ FIX: Inherit the background color directly from the database category configuration
            print("🎨 Updating screen background color to category color asset map target: \(matched.category.name)")
            currentBackgroundColor = matched.category.color
        } else {
            print("⚠️ Match Failed! '\(detected)' doesn't exist inside the active sounds database array.")
            print("   Available database labels were: \(sounds.map { $0.name })")
            
            // Fallback strategy if database structure breaks:
            let targetSeverity: Int = pattern.priority / 50
            if let category = categories.first(where: { $0.severity == targetSeverity }) {
                currentBackgroundColor = category.color
            }
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
