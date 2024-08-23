//
//  MotionManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private final let LOW_PASS_ALPHA = 0.12
    
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    // units are in g's
    // 46% of braking is 0 to -0.05
    // 28% is -0.05 to -0.1
    // 11.5% is -0.1 to -0.15
    // 7% is -0.15 to -0.2
    // 6% is -0.2 to -0.3
    // Remaining ~1.5% is above
    @Published var accelZ: [Double] = []
    
    // units are in radians / second
    @Published var angleVelZ: [Double] = []
    @Published var smoothAngleVelZ: Double = 0.0
    
    init() {
        requestMotionData()
    }
    
    func requestMotionData() {
        // Throttle updates to every 0.1 seconds
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (data: CMDeviceMotion?, error: Error?) in
            guard let data = data else { return }
            let gyro = data.rotationRate
            let acceleration = data.userAcceleration
            
            DispatchQueue.main.async {
                self?.accelZ.append(Double(acceleration.z))
                self?.angleVelZ.append(Double(gyro.z))
                
                self?.applyLowPassFilter(to: Double(gyro.z))
                
                // Limit array size to 100 points
                if self?.accelZ.count ?? 0 > 100 {
                    self?.accelZ.removeFirst()
                    self?.angleVelZ.removeFirst()
                }
            }
        }
    }
    
    private func applyLowPassFilter(to newAngleVelZ: Double) {
        // guard agaisnt sudden movements
        guard abs(newAngleVelZ) <= 5 else { return }
        guard abs(newAngleVelZ - smoothAngleVelZ) <= 0.5 else { return }
        
        smoothAngleVelZ = LOW_PASS_ALPHA * newAngleVelZ + (1 - LOW_PASS_ALPHA) * smoothAngleVelZ
    }

}
