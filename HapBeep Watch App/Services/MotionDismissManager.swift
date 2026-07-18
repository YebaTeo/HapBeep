//
//  MotionDismissManager.swift
//

import Foundation
import CoreMotion

@Observable
final class MotionDismissManager {

    private let motionManager = CMMotionManager()

    var onDismiss: (() -> Void)?

    private var canDismiss = true

    private let threshold = -7.0

    func start() {

        guard motionManager.isDeviceMotionAvailable else {
            return
        }

        canDismiss = true

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in

            guard
                let self,
                let motion
            else { return }

            self.detectFlick(motion)
        }

        print("✅ Motion Started")
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        canDismiss = true
    }

    private func detectFlick(_ motion: CMDeviceMotion) {

        let rotation = motion.rotationRate

        let axisValue = rotation.x

        guard canDismiss else { return }

        if axisValue < threshold {

            canDismiss = false

            onDismiss?()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.canDismiss = true
            }
        }
    }
}
