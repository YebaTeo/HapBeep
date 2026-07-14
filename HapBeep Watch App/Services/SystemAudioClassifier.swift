//
//  SystemAudioClassifier.swift
//  HapBeep Watch App
//
//  Created by Muhammad Alief Rahman Fardillah on 15/07/26.
//

import Foundation
import AVFoundation
import SoundAnalysis
import CoreML


@Observable
final class SystemAudioClassifier: NSObject {
    
    var detectedSound: String?
    
    private let audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private var request: SNClassifySoundRequest?
    
    private let supportedSound: Set<String> = [
        "car_horn", "siren", "vehicle", "reverse_beeper"
    ]
    
    func start() throws {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        analyzer = SNAudioStreamAnalyzer(format: format)
        request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        
        guard let analyzer, let request = request else {
            return
        }
        
        try analyzer.add(request, withObserver: self)
        
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: format) { [weak self] buffer, time in
            self?.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

extension SystemAudioClassifier : SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else {
            return
        }
        
        guard let best = result.classifications.first else {
            return
        }
        
        guard best.confidence > 0.6 else {
            return
        }
        
        if supportedSound.contains(best.identifier) {
            DispatchQueue.main.async {
                self.detectedSound = best.identifier
            }
        }
        
        func request(_ request: SNRequest, didFailWithError error: Error) {
            print(error)
        }
        
        func requestDidComplete(_ request: SNRequest) {
            
        }
    }
}
