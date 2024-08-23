//
//  ContentView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/20/24.
//

import SwiftUI
import CoreMotion
import Charts

struct ContentView: View {
    @StateObject private var dynamicMusicLoopController: DynamicMusicLoopController
    @ObservedObject private var audioManager: AudioManager
    
    init() {
        let motionManager = MotionManager()
        let locationManager = LocationManager()
        let audioManager = AudioManager()
        _dynamicMusicLoopController = StateObject(wrappedValue: DynamicMusicLoopController(motionManager: motionManager, locationManager: locationManager, audioManager: audioManager))
        _audioManager = ObservedObject(wrappedValue: audioManager)
    }
    
    var body: some View {
        VStack {
            // Play/Pause Button
            PlayPauseButton(isPlaying: $audioManager.isPlaying) {
                audioManager.togglePlayPause()
            }
            .padding()
            
            // Audio Track Sliders
            ForEach(audioManager.tracks, id: \.id) { track in
                TrackSliderView(track: track, audioManager: audioManager)
            }
        }
        .onAppear {
            dynamicMusicLoopController.start()
        }
        .onDisappear {
            dynamicMusicLoopController.stop()
        }
    }
}

struct TrackSliderView: View {
    let track: AudioManager.Track
    let audioManager: AudioManagerProtocol
    
    var body: some View {
        VStack {
            Text(track.name.capitalized)
            HStack {
                Text("Volume")
                Slider(value: Binding(
                    get: { track.volume },
                    set: { audioManager.adjustVolume(for: track.name, to: $0) }
                ), in: 0...1)
            }
            HStack {
                Text("Pan")
                Slider(value: Binding(
                    get: { track.pan },
                    set: { audioManager.adjustPan(for: track.name, to: $0) }
                ), in: -1...1)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
