import Foundation
import HealthKit

// MARK: - Safe Background Wake Lock Engine
class WatchLockEngine: NSObject, HKWorkoutSessionDelegate {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [HKQuantityType.workoutType()]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }
    
    func startLock() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session.delegate = self
            
            session.prepare()
            session.startActivity(with: Date())
            
            self.workoutSession = session
        } catch {
            print("Failed to bind watchOS background frame context: \(error.localizedDescription)")
        }
    }
    
    func stopLock() {
        guard let session = workoutSession else { return }
        session.end()
        self.workoutSession = nil
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
         if toState == .ended || toState == .stopped {
            DispatchQueue.main.async {
                self.workoutSession = nil
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.workoutSession = nil
        }
    }
}
