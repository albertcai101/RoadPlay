//
//  DynamicMusicController.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import Combine
import SwiftUI

protocol DynamicMusicLoopControllerProtocol {
    func start()
    func stop()
}

class DynamicMusicLoopController: ObservableObject, DynamicMusicLoopControllerProtocol {
    let motionManager: MotionManagerProtocol
    let locationManager: LocationManagerProtocol
    let audioManager: AudioManagerProtocol
    
    private var timer: Timer?
    
    init(motionManager: MotionManagerProtocol, locationManager: LocationManagerProtocol, audioManager: AudioManagerProtocol) {
        self.motionManager = motionManager
        self.locationManager = locationManager
        self.audioManager = audioManager
    }
    
    func start() {
        motionManager.startUpdates()
        locationManager.startUpdates()
        startDynamicMusicLoop()
    }
    
    func stop() {
        motionManager.stopUpdates()
        locationManager.stopUpdates()
        if audioManager.isPlaying {
            audioManager.togglePlayPause()
        }
        stopDynamicMusicLoop()
    }
    
    private func startDynamicMusicLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateDynamicMusic()
        }
    }
    
    private func stopDynamicMusicLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateDynamicMusic() {
        let angularVelocity = motionManager.smoothAngleVelZ
        let sign = angularVelocity >= 0 ? 1.0 : -1.0
        let panValue = Float(sign * sqrt(abs(angularVelocity)) / 0.5)
        let clampedPanValue = min(max(panValue, -0.5), 0.5)
        
        audioManager.adjustPanForAllTracks(to: clampedPanValue)
    }
}
