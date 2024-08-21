//
//  MotionManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var accelZ: [Double] = []
    @Published var angleVelZ: [Double] = []
    
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
                
                // Limit array size to 100 points
                if self?.accelZ.count ?? 0 > 100 {
                    self?.accelZ.removeFirst()
                    self?.angleVelZ.removeFirst()
                }
            }
        }
    }
}
