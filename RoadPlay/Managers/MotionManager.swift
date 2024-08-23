//
//  MotionManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import CoreMotion
import Combine

protocol MotionManagerProtocol: AnyObject {
    var smoothAngleVelZ: Double { get }
    var accelZ: [Double] { get }
    var angleVelZ: [Double] { get }
    func startUpdates()
    func stopUpdates()
}

class MotionManager: ObservableObject, MotionManagerProtocol {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private final let LOW_PASS_ALPHA = 0.12
    
    @Published var accelZ: [Double] = []
    @Published var angleVelZ: [Double] = []
    @Published var smoothAngleVelZ: Double = 0.0
    
    private var updateTimer: Timer?
    
    init() {
        configureMotionManager()
    }
    
    private func configureMotionManager() {
        motionManager.deviceMotionUpdateInterval = 0.1
    }
    
    func startUpdates() {
        guard !motionManager.isDeviceMotionActive else { return }
        
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (data: CMDeviceMotion?, error: Error?) in
            guard let data = data else {
                // Handle error
                return
            }
            self?.processMotionData(data)
        }
        
        // Use a timer to update published properties on main thread
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePublishedProperties()
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        updateTimer?.invalidate()
    }
    
    private func processMotionData(_ data: CMDeviceMotion) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.accelZ.append(data.userAcceleration.z)
            self.angleVelZ.append(data.rotationRate.z)
            self.applyLowPassFilter(to: data.rotationRate.z)
            
            // Limit array size to 100 points
            if self.accelZ.count > 100 {
                self.accelZ.removeFirst()
                self.angleVelZ.removeFirst()
            }
        }
    }
    
    private func updatePublishedProperties() {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    private func applyLowPassFilter(to newAngleVelZ: Double) {
        // Guard against sudden movements
        guard abs(newAngleVelZ) <= 5 else { return }
        guard abs(newAngleVelZ - smoothAngleVelZ) <= 0.5 else { return }
        
        smoothAngleVelZ = LOW_PASS_ALPHA * newAngleVelZ + (1 - LOW_PASS_ALPHA) * smoothAngleVelZ
    }
}
