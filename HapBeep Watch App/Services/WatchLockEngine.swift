import Foundation
import HealthKit
import OSLog

// MARK: - Safe Background Wake Lock Engine
class WatchLockEngine: NSObject, HKWorkoutSessionDelegate {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private let logger = Logger(subsystem: "com.hapbeep.app", category: "WatchLockEngine")
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // Fix: Correctly using HKObjectType instead of the invalid HKQuantityType.workoutType()
        let typesToShare: Set<HKSampleType> = [HKObjectType.workoutType()]
        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, error in
            if !success {
                self?.logger.error("HealthKit Authorization Failed: \(String(describing: error))")
            }
        }
    }
    
    func startLock() {
        guard workoutSession == nil else { return }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            
            session.delegate = self
            builder.delegate = self
            
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            session.startActivity(with: Date())
            builder.beginCollection(withStart: Date()) { [weak self] success, error in
                guard let self = self else { return }
                if success {
                    self.logger.log("🔒 Background lock achieved. Data tracking streaming online.")
                } else if let error = error {
                    self.logger.error("Builder failed to spin collection up: \(error.localizedDescription)")
                }
            }
            
            self.workoutSession = session
            self.workoutBuilder = builder
        } catch {
            logger.error("Failed to bind watchOS background frame context: \(error.localizedDescription)")
        }
    }
    
    func stopLock() {
        guard let session = workoutSession else { return }
        
        session.end()
        workoutBuilder?.endCollection(withEnd: Date()) { [weak self] _, _ in
            self?.workoutBuilder?.finishWorkout { _, _ in }
        }
        
        self.workoutSession = nil
        self.workoutBuilder = nil
        logger.log("🔓 Session terminated cleanly.")
    }
    
    // MARK: - HKWorkoutSessionDelegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        logger.log("Session shifted state from \(fromState.rawValue) to \(toState.rawValue)")
        if toState == .ended || toState == .stopped {
            DispatchQueue.main.async { [weak self] in
                self?.workoutSession = nil
                self?.workoutBuilder = nil
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        logger.error("Session runtime crash: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.workoutSession = nil
            self?.workoutBuilder = nil
        }
    }
}

extension WatchLockEngine: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
    }
    
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKQuantityType>) {
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
}
