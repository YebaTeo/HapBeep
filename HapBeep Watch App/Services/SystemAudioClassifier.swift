import Foundation
import AVFoundation
import SoundAnalysis
import CoreML

@Observable
final class SystemAudioClassifier: NSObject {

    var detectedSound: String? // SwiftUI ContentView explicitly hooks up to this property

    private let audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "com.hapbeep.analysisQueue")

    private var systemRequest: SNClassifySoundRequest?
    
    // Core ML Tabular Classification Model instance
    private var tabularModel: ClassificationTrafficRoad_2?

    // Storage for SoundAnalysis confidence values
    private var carHornConfidence: Double = 0.0
    private var trafficNoiseConfidence: Double = 0.0
    private var vehicleSkiddingConfidence: Double = 0.0
    private var reverseBeepsConfidence: Double = 0.0
    private var knockConfidence: Double = 0.0
    private var emergencyVehicleConfidence: Double = 0.0

    // Thread-safe storage for the latest manual audio features
    struct AudioFeatures {
        let rms: Double
        let peak: Double
        let zeroCrossingRate: Double
        let duration: Double
    }
    private var latestFeatures = AudioFeatures(rms: 0.0, peak: 0.0, zeroCrossingRate: 0.0, duration: 0.0)

    override init() {
        super.init()
        setupTabularModel()
    }

    private func setupTabularModel() {
        do {
            let config = MLModelConfiguration()
            self.tabularModel = try ClassificationTrafficRoad_2(configuration: config)
        } catch {
            print("Failed to load Tabular Model: \(error.localizedDescription)")
        }
    }

    func start() throws {
        guard !audioEngine.isRunning else { return }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        analyzer = SNAudioStreamAnalyzer(format: format)

        guard let analyzer else { return }

        systemRequest = try SNClassifySoundRequest(classifierIdentifier: .version1)
        try analyzer.add(systemRequest!, withObserver: self)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 2048,
            format: format
        ) { [weak self] buffer, time in
            guard let self = self else { return }
            
            self.analysisQueue.async {
                let extractedFeatures = self.extractAudioFeatures(from: buffer)
                self.latestFeatures = extractedFeatures
                
                self.analyzer?.analyze(
                    buffer,
                    atAudioFramePosition: time.sampleTime
                )
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        print("Audio Engine Started")
    }

    func stop() {
        guard audioEngine.isRunning else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        analyzer = nil
        systemRequest = nil
        
        carHornConfidence = 0.0
        trafficNoiseConfidence = 0.0
        vehicleSkiddingConfidence = 0.0
        reverseBeepsConfidence = 0.0
        knockConfidence = 0.0
        emergencyVehicleConfidence = 0.0
        latestFeatures = AudioFeatures(rms: 0.0, peak: 0.0, zeroCrossingRate: 0.0, duration: 0.0)
        
        detectedSound = nil

        print("Audio Engine Stopped")
    }

    private func extractAudioFeatures(from buffer: AVAudioPCMBuffer) -> AudioFeatures {
        guard let channelData = buffer.floatChannelData?[0] else {
            return AudioFeatures(rms: 0.0, peak: 0.0, zeroCrossingRate: 0.0, duration: 0.0)
        }

        let frameLength = Int(buffer.frameLength)
        var squareSum: Float = 0.0
        var peakValue: Float = 0.0
        var zeroCrossings = 0

        for i in 0..<frameLength {
            let sample = channelData[i]
            squareSum += sample * sample

            let absSample = abs(sample)
            if absSample > peakValue {
                peakValue = absSample
            }

            if i > 0 {
                let prevSample = channelData[i - 1]
                if (sample >= 0 && prevSample < 0) || (sample < 0 && prevSample >= 0) {
                    zeroCrossings += 1
                }
            }
        }

        let rms = sqrt(squareSum / Float(frameLength))
        let zcr = Double(zeroCrossings) / Double(frameLength)
        let duration = Double(frameLength) / buffer.format.sampleRate

        return AudioFeatures(
            rms: Double(rms),
            peak: Double(peakValue),
            zeroCrossingRate: zcr,
            duration: duration
        )
    }

    // MARK: - Tabular Prediction Pipeline
    
    fileprivate func runTabularPrediction(features: AudioFeatures) {
        guard let model = tabularModel else { return }

        do {
            let prediction = try model.prediction(
                car_horn_conf: carHornConfidence,
                traffic_noise_conf: trafficNoiseConfidence,
                vehicle_skidding_conf: vehicleSkiddingConfidence,
                reverse_beeps_conf: reverseBeepsConfidence,
                knock_conf: knockConfidence,
                emergency_vehicle_conf: emergencyVehicleConfidence,
                rms: features.rms,
                peak: features.peak,
                zero_crossing_rate: features.zeroCrossingRate,
                duration: features.duration
            )

            let probabilities = prediction.featureValue(for: "labelProbability")?.dictionaryValue
            
            print("🤖 [Custom Tabular Inference] Evaluated Confidences:")
            if let probabilities = probabilities {
                for (label, conf) in probabilities {
                    if let labelString = label as? String, let confDouble = conf as? Double {
                        print(" • \(labelString): \(String(format: "%.3f", confDouble))")
                    }
                }
            }

            let modelConfidence = probabilities?[prediction.label]?.doubleValue ?? 0.0
            let isCustomTargetLabel = prediction.label == "car_crash" || prediction.label == "machine_faulty"

            // 🌟 FIXED LOGIC LAYER: Handle clear confirmation parameters
            if prediction.label == "silence" {
                if modelConfidence >= 0.80 {
                    print("[Custom Tabular Inference] Silence verified with high confidence (\(String(format: "%.3f", modelConfidence))), clearing background noises safely.")
                    Task { @MainActor in
                        self.detectedSound = nil
                    }
                } else {
                    print("[Custom Tabular Inference] Tabular predicted 'silence' but confidence was weak (\(String(format: "%.3f", modelConfidence))). Keeping Apple state records.")
                }
                return
            }

            // 🌟 VALIDATION ENFORCEMENT: Enforce the explicit 80% confidence ceiling for custom pipeline triggers
            if isCustomTargetLabel && modelConfidence >= 0.80 {
                print("[Custom Tabular Inference] Accepted Trigger -> output: \(prediction.label) with confidence \(String(format: "%.3f", modelConfidence))")
                Task { @MainActor in
                    self.detectedSound = prediction.label
                }
            } else {
                print("[Custom Tabular Inference] Dropped '\(prediction.label)' (Confidence: \(String(format: "%.3f", modelConfidence))). Required: Custom Label >= 0.80")
            }
            
        } catch {
            print("Tabular CoreML Prediction Failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - SNResultsObserving

extension SystemAudioClassifier: SNResultsObserving {

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let blockResult = result as? SNClassificationResult else { return }

        var currentCarHorn = 0.0
        var currentTrafficNoise = 0.0
        var currentVehicleSkidding = 0.0
        var currentReverseBeeps = 0.0
        var currentKnock = 0.0
        var currentEmergencyVehicle = 0.0

        for classification in blockResult.classifications {
            switch classification.identifier {
            case "car_horn":            currentCarHorn = classification.confidence
            case "traffic_noise":       currentTrafficNoise = classification.confidence
            case "vehicle_skidding":    currentVehicleSkidding = classification.confidence
            case "reverse_beeps":       currentReverseBeeps = classification.confidence
            case "knock":               currentKnock = classification.confidence
            case "emergency_vehicle":   currentEmergencyVehicle = classification.confidence
            default: break
            }
        }

        print("[Apple SoundAnalysis .version1] Extracting confidences:")
        print(" • car_horn: \(String(format: "%.3f", currentCarHorn))")
        print(" • traffic_noise: \(String(format: "%.3f", currentTrafficNoise))")
        print(" • vehicle_skidding: \(String(format: "%.3f", currentVehicleSkidding))")
        print(" • reverse_beeps: \(String(format: "%.3f", currentReverseBeeps))")
        print(" • knock: \(String(format: "%.3f", currentKnock))")
        print(" • emergency_vehicle: \(String(format: "%.3f", currentEmergencyVehicle))")

        // Map discrete targeted sound variants
        let confidenceMap: [String: Double] = [
            "car_horn": currentCarHorn,
            "vehicle_skidding": currentVehicleSkidding,
            "reverse_beeps": currentReverseBeeps,
            "knock": currentKnock,
            "emergency_vehicle": currentEmergencyVehicle
        ]
        
        // Output clean intentional events immediately if they surpass standard certainty
        if let topAppleEvent = confidenceMap.max(by: { $0.value < $1.value }), topAppleEvent.value > 0.40 {
            print("[Apple Stream Parser] High confidence intentional event matched: \(topAppleEvent.key) (\(topAppleEvent.value))")
            Task { @MainActor in
                self.detectedSound = topAppleEvent.key
            }
        }

        self.carHornConfidence = currentCarHorn
        self.trafficNoiseConfidence = currentTrafficNoise
        self.vehicleSkiddingConfidence = currentVehicleSkidding
        self.reverseBeepsConfidence = currentReverseBeeps
        self.knockConfidence = currentKnock
        self.emergencyVehicleConfidence = currentEmergencyVehicle

        // Evaluate custom inference matrices contextually
        self.runTabularPrediction(features: self.latestFeatures)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ SoundAnalysis Error: \(error.localizedDescription)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("🍎 Apple classifier request segment completed")
    }
}
