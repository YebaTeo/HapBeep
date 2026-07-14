//
//  HapticsVocabulary.swift
//  HapBeep Watch App
//
//  Created by Yeba Teo on 14/07/26.
//
import Foundation
import Observation
import WatchKit

// MARK: - Pattern model

struct HapticStep {
    let haptic: WKHapticType
    /// Pause AFTER this tap, in seconds.
    let delayAfter: TimeInterval
}

enum RoadPattern: String, CaseIterable, Identifiable, Codable {
    // Information tier — calm, light (.click)
    case information  = "ℹ️ Information"
    case information2 = "ℹ️ Information 2"
    case information3 = "ℹ️ Information 3"

    // Caution tier — warning, medium (.directionUp)
    case caution  = "⚠️ Caution"
    case caution2 = "⚠️ Caution 2"
    case caution3 = "⚠️ Caution 3"

    // Critical tier — strongest (.notification), fixed
    case critical = "🚨 Critical"

    var id: String { rawValue }

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

        // Rhythm: tick · tick · tick  (3 even beats)
        case .information:
            return [
                .init(haptic: .success, delayAfter: 0.35),
                .init(haptic: .success, delayAfter: 0.35),
                .init(haptic: .success, delayAfter: 0.0),
            ]

        // Rhythm: tick-tick-tick-tick  (4 rapid beats)
        // Faster cadence — same light type, clearly more "busy" than the triple.
        case .information2:
            return [
                .init(haptic: .success, delayAfter: 0.15),
                .init(haptic: .success, delayAfter: 0.15),
                .init(haptic: .success, delayAfter: 0.15),
                .init(haptic: .success, delayAfter: 0.0),
                
            ]

        // Rhythm: tick ········ tick  (2 slow beats)
        // Minimal and widely spaced — simplest pattern in the info tier.
        case .information3:
            return [
                .init(haptic: .success, delayAfter: 0.65),
                .init(haptic: .success, delayAfter: 0.0),
            ]

        // Rhythm: tap-tap ··· tap-tap  (double-knock)
        case .caution:
            return [
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.50),
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.0),
            ]

        // Rhythm: tap-tap-tap  (triple rapid knock)
        // Three tight taps with no internal gap — distinct from caution's paired shape.
        case .caution2:
            return [
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.0),
            ]

        // Rhythm: tap ··· tap-tap ··· tap-tap-tap  (escalating 1-2-3)
        // Builds in count each beat group — the escalation shape is unmistakable.
        case .caution3:
            return [
                .init(haptic: .directionUp, delayAfter: 0.40),
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.40),
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.12),
                .init(haptic: .directionUp, delayAfter: 0.0),
            ]

        // Rhythm: brr-brr-brr ··· BANG · BANG · BANG  (burst then slams)
        case .critical:
            return [
                .init(haptic: .notification, delayAfter: 0.09),
                .init(haptic: .notification, delayAfter: 0.09),
                .init(haptic: .notification, delayAfter: 0.09),
                .init(haptic: .notification, delayAfter: 0.35),
                .init(haptic: .notification, delayAfter: 0.20),
                .init(haptic: .notification, delayAfter: 0.20),
                .init(haptic: .notification, delayAfter: 0.20),
                .init(haptic: .notification, delayAfter: 0.20),

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
