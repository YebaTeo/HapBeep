import Foundation
import AVFoundation
import SoundAnalysis
import CoreML

@Observable
final class SystemAudioClassifier: NSObject {

    var detectedSound: String?

    private let audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "com.hapbeep.analysisQueue")

    private var systemRequest: SNClassifySoundRequest?
    
    // Three Core ML Tabular Classification Model instances
    private var tabularModel2: ClassificationTrafficRoad_2?
    private var tabularModel10: ClassificationTrafficRoad_10?
    private var tabularModel12: ClassificationTrafficRoad_12?

    // Storage for SoundAnalysis confidence values
    private var carHornConfidence: Double = 0.0
    private var trafficNoiseConfidence: Double = 0.0
    private var vehicleSkiddingConfidence: Double = 0.0
    private var reverseBeepsConfidence: Double = 0.0
    private var knockConfidence: Double = 0.0
    private var emergencyVehicleConfidence: Double = 0.0

    // Tracks whether Apple's raw sound analyzer already found a high-confidence match in the current frame
    private var didAppleMatchIntentionalEvent: Bool = false

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
        setupTabularModels()
    }

    private func setupTabularModels() {
        do {
            let config = MLModelConfiguration()
            self.tabularModel2 = try ClassificationTrafficRoad_2(configuration: config)
            self.tabularModel10 = try ClassificationTrafficRoad_10(configuration: config)
            self.tabularModel12 = try ClassificationTrafficRoad_12(configuration: config)
            print("Successfully loaded 3 tabular models (2, 10, and 12).")
        } catch {
            print("Failed to load Tabular Models: \(error.localizedDescription)")
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
        didAppleMatchIntentionalEvent = false
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

    // MARK: - Tabular Weighted Soft Voting Prediction Pipeline
    
    fileprivate func runTabularPrediction(features: AudioFeatures) {
        if didAppleMatchIntentionalEvent {
            print("⚠️ [Tabular Pipeline Intercepted] Apple classifier has priority. Skipping custom prediction pass.")
            return
        }

        guard let model2 = tabularModel2,
              let model10 = tabularModel10,
              let model12 = tabularModel12 else {
            print("⚠️ [Tabular Pipeline] One or more models are not initialized.")
            return
        }

        do {
            // 1. Gather individual predictions from all 3 active models
            let pred2 = try model2.prediction(
                car_horn_conf: carHornConfidence, traffic_noise_conf: trafficNoiseConfidence,
                vehicle_skidding_conf: vehicleSkiddingConfidence, reverse_beeps_conf: reverseBeepsConfidence,
                knock_conf: knockConfidence, emergency_vehicle_conf: emergencyVehicleConfidence,
                rms: features.rms, peak: features.peak, zero_crossing_rate: features.zeroCrossingRate, duration: features.duration
            )

            let pred10 = try model10.prediction(
                car_horn_conf: carHornConfidence, traffic_noise_conf: trafficNoiseConfidence,
                vehicle_skidding_conf: vehicleSkiddingConfidence, reverse_beeps_conf: reverseBeepsConfidence,
                knock_conf: knockConfidence, emergency_vehicle_conf: emergencyVehicleConfidence,
                rms: features.rms, peak: features.peak, zero_crossing_rate: features.zeroCrossingRate, duration: features.duration
            )
            
            let pred12 = try model12.prediction(
                car_horn_conf: carHornConfidence, traffic_noise_conf: trafficNoiseConfidence,
                vehicle_skidding_conf: vehicleSkiddingConfidence, reverse_beeps_conf: reverseBeepsConfidence,
                knock_conf: knockConfidence, emergency_vehicle_conf: emergencyVehicleConfidence,
                rms: features.rms, peak: features.peak, zero_crossing_rate: features.zeroCrossingRate, duration: features.duration
            )

            // 2. Extract probability dictionaries
            let probs2 = pred2.featureValue(for: "labelProbability")?.dictionaryValue ?? [:]
            let probs10 = pred10.featureValue(for: "labelProbability")?.dictionaryValue ?? [:]
            let probs12 = pred12.featureValue(for: "labelProbability")?.dictionaryValue ?? [:]

            // 3. Accumulate weighted probabilities (Soft Voting)
            var accumulatedProbabilities: [String: Double] = [:]
            
            // Define weights: Model 10 is twice as significant as Model 2 and 12
            let weightedDicts: [([AnyHashable: Any], Double)] = [
                (probs2, 1.0),
                (probs10, 2.0), // Higher significance factor applied here
                (probs12, 1.0)
            ]
            
            let totalEnsembleWeight = weightedDicts.reduce(0.0) { $0 + $1.1 } // Evaluates to 4.0

            for (dict, weight) in weightedDicts {
                for (labelObj, confidenceObj) in dict {
                    if let label = labelObj as? String, let confidence = confidenceObj as? Double {
                        accumulatedProbabilities[label, default: 0.0] += (confidence * weight)
                    }
                }
            }

            // Calculate true weighted averages across the ensemble
            var averageProbabilities: [String: Double] = [:]
            for (label, weightedTotalConfidence) in accumulatedProbabilities {
                averageProbabilities[label] = weightedTotalConfidence / totalEnsembleWeight
            }

            // 4. Find the winning label based on highest average confidence
            guard let winningElement = averageProbabilities.max(by: { $0.value < $1.value }) else { return }
            let votedLabel = winningElement.key
            let ensembleConfidence = winningElement.value

            print("🤖 [Custom Ensemble Weighted Soft Voting] Evaluated Confidences:")
            for (label, conf) in averageProbabilities {
                print(" • \(label): \(String(format: "%.3f", conf))")
            }

            // 5. Execution Layer Logic (With Custom Threshold Checks per Custom Label)
            if votedLabel == "silence" {
                if ensembleConfidence >= 0.75 {
                    print("[Ensemble Inference] Silence verified with high confidence (\(String(format: "%.3f", ensembleConfidence))), clearing background noises safely.")
                    Task { @MainActor in
                        self.detectedSound = nil
                    }
                } else {
                    print("[Ensemble Inference] Ensemble predicted 'silence' but confidence was weak (\(String(format: "%.3f", ensembleConfidence))). Keeping Apple state records.")
                }
                return
            }

            // Assign unique threshold levels to target custom conditions
            var dynamicThreshold: Double? = nil
            if votedLabel == "car_crash" {
                dynamicThreshold = 0.85 // Car Crash set to 80%
            } else if votedLabel == "machine_faulty" {
                dynamicThreshold = 0.90 // Machine Faulty set to 75%
            }

            if let requiredThreshold = dynamicThreshold, ensembleConfidence >= requiredThreshold {
                print("[Ensemble Inference] Accepted Trigger -> output: \(votedLabel) with ensemble confidence \(String(format: "%.3f", ensembleConfidence))")
                Task { @MainActor in
                    self.detectedSound = votedLabel
                }
            } else {
                let requiredString = dynamicThreshold != nil ? String(format: "%.2f", dynamicThreshold!) : "N/A"
                print("[Ensemble Inference] Dropped '\(votedLabel)' (Ensemble Confidence: \(String(format: "%.3f", ensembleConfidence))). Required: Custom Label >= \(requiredString)")
            }
            
        } catch {
            print("Ensemble CoreML Prediction Failed: \(error.localizedDescription)")
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

        let confidenceMap: [String: Double] = [
            "car_horn": currentCarHorn,
            "vehicle_skidding": currentVehicleSkidding,
            "reverse_beeps": currentReverseBeeps,
            "knock": currentKnock,
            "emergency_vehicle": currentEmergencyVehicle
        ]
        
        self.didAppleMatchIntentionalEvent = false
        
        if let topAppleEvent = confidenceMap.max(by: { $0.value < $1.value }), topAppleEvent.value >= 0.60 {
            print("[Apple Stream Parser] High confidence intentional event matched: \(topAppleEvent.key) (\(topAppleEvent.value))")
            
            self.didAppleMatchIntentionalEvent = true
            
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

        self.runTabularPrediction(features: self.latestFeatures)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ SoundAnalysis Error: \(error.localizedDescription)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("🍎 Apple classifier request segment completed")
    }
}
