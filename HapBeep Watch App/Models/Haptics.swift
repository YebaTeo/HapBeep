//
//  HapticsVocabulary.swift
//  HapBeep Watch App
//
//  Created by Yeba Teo on 14/07/26.
//
import Foundation
import Observation
import WatchKit

struct HapticStep {
    let haptic: WKHapticType
    /// Pause AFTER this tap, in seconds.
    let delayAfter: TimeInterval
}

enum RoadPattern: String, CaseIterable, Identifiable, Codable {
    case information  = "Information"
    case information2 = "Information 2"
    case information3 = "Information 3"
    case caution  = "Caution"
    case caution2 = "Caution 2"
    case caution3 = "Caution 3"
    case critical = "Critical"

    var id: String { rawValue }

    /// Maps a SoundAnalysis classifier identifier to the appropriate haptic tier.
    static func pattern(for classifierIdentifier: String) -> RoadPattern {
        switch classifierIdentifier {
        case "emergency_vehicle":                              return .critical
        case "car_horn", "traffic_noise", "vehicle_skidding": return .caution
        default:                                               return .information
        }
    }

    /// Higher wins preemption in the detection state machine.
    var priority: Int {
        switch self {
        case .information, .information2, .information3: return 0
        case .caution, .caution2, .caution3:             return 50
        case .critical:                                  return 100
        }
    }
    /// Repeat count — more urgent alerts repeat longer to cut through distraction.
    var alertRepeats: Int {
        switch self {
        case .information, .information2, .information3: return 1
        case .caution, .caution2, .caution3:             return 2
        case .critical:                                  return 3
        }
    }
    var steps: [HapticStep] {
        switch self {
        case .information:
            return [
                .init(haptic: .start, delayAfter: 0.35),
                .init(haptic: .stop,  delayAfter: 0.35),
                .init(haptic: .start, delayAfter: 0.35),
                .init(haptic: .stop,  delayAfter: 0.0),
            ]
        case .information2:
            return [
                .init(haptic: .start, delayAfter: 0.15),
                .init(haptic: .stop,  delayAfter: 0.15),
                .init(haptic: .start, delayAfter: 0.15),
                .init(haptic: .stop,  delayAfter: 0.15),
                .init(haptic: .start, delayAfter: 0.15),
                .init(haptic: .stop,  delayAfter: 0.15),
                .init(haptic: .start, delayAfter: 0.15),
                .init(haptic: .stop,  delayAfter: 0.0),
            ]
        case .information3:
            return [
                .init(haptic: .start, delayAfter: 0.65),
                .init(haptic: .stop,  delayAfter: 0.65),
                .init(haptic: .start, delayAfter: 0.65),
                .init(haptic: .stop,  delayAfter: 0.0),
            ]
        case .caution:
            return [
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.50),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.50),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.0),
            ]
        case .caution2:
            return [
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.35),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.35),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.0),
            ]
        case .caution3:
            return [
                .init(haptic: .success, delayAfter: 0.40),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.40),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.40),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.40),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.40),
                .init(haptic: .success, delayAfter: 0.12),
                .init(haptic: .success, delayAfter: 0.40),
                .init(haptic: .success, delayAfter: 0.0),
            ]
        case .critical:
            return [
                .init(haptic: .failure,      delayAfter: 0.06),
                .init(haptic: .notification, delayAfter: 0.06),
                .init(haptic: .failure,      delayAfter: 0.30),
                .init(haptic: .failure,      delayAfter: 0.06),
                .init(haptic: .notification, delayAfter: 0.30),
                .init(haptic: .notification, delayAfter: 0.15),
                .init(haptic: .notification, delayAfter: 0.15),
                .init(haptic: .notification, delayAfter: 0.0),
            ]
        }
    }
}

// MARK: - Player

@MainActor
@Observable
final class VocabularyPlayer {
    var isPlaying = false
    var nowPlaying: RoadPattern?

    private var currentTask: Task<Void, Never>?

    /// Plays a pattern with its alert repetition count.
    /// A new call with strictly higher priority preempts the current one.
    func play(_ pattern: RoadPattern) {
        if isPlaying {
            guard let current = nowPlaying,
                  pattern.priority > current.priority else { return }
            currentTask?.cancel()   // preemption: emergency > siren > ...
        }

        isPlaying = true
        nowPlaying = pattern
        currentTask = Task {
            for rep in 0..<pattern.alertRepeats {
                for step in pattern.steps {
                    guard !Task.isCancelled else { return }
                    WKInterfaceDevice.current().play(step.haptic)
                    if step.delayAfter > 0 {
                        try? await Task.sleep(for: .seconds(step.delayAfter))
                    }
                }
                // Gap between repetitions (skip after the last one)
                if rep < pattern.alertRepeats - 1 {
                    try? await Task.sleep(for: .seconds(0.9))
                }
            }
            guard !Task.isCancelled else { return }
            isPlaying = false
            nowPlaying = nil
        }
    }

    func stop() {
        currentTask?.cancel()
        isPlaying = false
        nowPlaying = nil
    }
}
