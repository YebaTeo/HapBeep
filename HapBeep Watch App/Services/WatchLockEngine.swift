import HealthKit

// MARK: - Safe Background Wake Lock Engine
class WatchLockEngine: NSObject, HKWorkoutSessionDelegate {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // We only request authorization for the generic workout wrapper, NO biometric types.
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [HKQuantityType.workoutType()]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in }
    }
    
    func startLock() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other // Tells the OS it is a custom utility behavior
        configuration.locationType = .indoor
        
        do {
            // Allocate a minimalist background session container
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session.delegate = self
            
            session.prepare()
            session.startActivity(with: Date())
            
            self.workoutSession = session
            print("🚀 App runtime background execution lock engaged safely.")
        } catch {
            print("❌ Failed to bind watchOS background frame context: \(error.localizedDescription)")
        }
    }
    
    func stopLock() {
        workoutSession?.end()
        self.workoutSession = nil
        print("🛑 App runtime background execution lock disengaged.")
    }
    
    // Minimalist Delegate Requirements
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}
