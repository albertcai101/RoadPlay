//
//  RoadPlayApp.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import SwiftUI
import AVFoundation

@main
struct RoadPlayApp: App {
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
}
