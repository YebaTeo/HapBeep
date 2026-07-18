import SwiftUI
import SwiftData
import Combine
import HealthKit

struct ContentView: View {
    @State var isSettingsVisible: Bool = false
    @State var isTutorialVisible: Bool = false
    
    @State private var activeSound: Sound?
    @State private var selectedIndex: Int = 0

    @Query(sort: \Sound.name) private var sounds: [Sound]
    @Query(sort: \Category.severity) private var categories: [Category]
    @State private var player = VocabularyPlayer()
    @State private var classifier = SystemAudioClassifier()
    @State private var motionDismiss = MotionDismissManager()
    
    @State private var currentBackgroundColor: Color = .primaryDarkBlue
    
    let initialCountdown: Int = 4
    @State private var countdown: Int = 4
    @State private var systemState: SystemState = .drivingOff
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let notificationManager = NotificationManager.shared
    
    // Instantiating the clean background lifecycle controller
    @State private var lockEngine = WatchLockEngine()
    
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
                    CircularProgressView(
                        countdown: $countdown,
                        maxCountdown: CGFloat(initialCountdown)
                    )
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
            
            if systemState != .starting, let sound = activeSound {
                ToolbarItem(placement: .bottomBar) {
                    Text(sound.cta)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }
            }
        }
        .onChange(of: systemState) { _, state in
            if state == .starting {
                // Instantly lock screen runtime foreground configuration
                lockEngine.startLock()
            } else if state == .drivingOn {
                try? classifier.start()
            } else if state == .drivingOff {
                classifier.stop()
                classifier.detectedSound = nil
                activeSound = nil
                // Shut down execution token to rest watch framework resources
                lockEngine.stopLock()
            }
        }
        .onChange(of: classifier.detectedSound) { _, detected in
            guard let detected else { return }
            handleDetectedSound(detected)
        }
        .onChange(of: activeSound) { _, sound in
            if sound != nil {
                motionDismiss.start()
            } else {
                motionDismiss.stop()
            }
        }
        .onReceive(timer) { _ in
            guard systemState == .starting else { return }
            if countdown < 1 {
                systemState = .drivingOn
                return
            }
            countdown -= 1
        }
        .sheet(isPresented: $isSettingsVisible) { SettingsView() }
        .sheet(isPresented: $isTutorialVisible) { TutorialView() }
        .onAppear {
            lockEngine.requestAuthorization()
            motionDismiss.onDismiss = { dismissAlert() }
        }
    }
    
    private func dismissAlert() {
        activeSound = nil
        classifier.detectedSound = nil
        currentBackgroundColor = .primaryDarkBlue
        motionDismiss.stop()
    }
    
    private func handleDetectedSound(_ detected: String) {
        let pattern = RoadPattern.pattern(for: detected)
        player.play(pattern)
        let matchedSound: Sound? = sounds.first { $0.name == detected }
        
        if let matched = matchedSound {
            activeSound = matched
            notificationManager.createNotificationBySound(sound: matched)
            currentBackgroundColor = matched.category.color
        } else {
            let targetSeverity: Int = pattern.priority / 50
            if let category = categories.first(where: { $0.severity == targetSeverity }) {
                currentBackgroundColor = category.color
            }
        }
    }

    func startDrivingMode() { systemState = .starting }
    func stopDrivingMode() {
        countdown = initialCountdown
        systemState = .drivingOff
        activeSound = nil
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
