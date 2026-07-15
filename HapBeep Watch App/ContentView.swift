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
    @Query(sort: \Category.severity) private var categories: [Category]
    @State private var player = VocabularyPlayer()
    @State private var classifier = SystemAudioClassifier()
    
    @State private var currentBackgroundColor: Color = .primaryDarkBlue
    
    private var activeSoundName: String {
        if !isStartingDrivingMode || countdown >= 0{
            return "Driving Mode: ON"
        }
        if let detectedSound = classifier.detectedSound {
            return detectedSound
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
                            activeSound  = nil
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
            .task {
                    guard !sounds.isEmpty else { return }

                    activeSound = sounds[selectedIndex]

                    try? classifier.start()
                    print(activeSound?.name ?? "nil")

                    selectedIndex = (selectedIndex + 1) % sounds.count
                    
                player.play(activeSound?.category.hapticPattern ?? .caution)
                    
                
            }
            .onChange(of: classifier.detectedSound) { detected in
                guard let detected else { return }
                let pattern = RoadPattern.pattern(for: detected)
                player.play(pattern)
                // priority 0 → severity 0, 50 → 1, 100 → 2
                if let category = categories.first(where: { $0.severity == pattern.priority / 50 }) {
                    currentBackgroundColor = category.color
                }
            }
            .onChange(of: player.isPlaying) { isPlaying in
                if !isPlaying {
                    currentBackgroundColor = .primaryDarkBlue
                    classifier.detectedSound = nil
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
