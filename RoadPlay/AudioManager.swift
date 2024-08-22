//
//  AudioManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/22/24.
//

import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    struct Track: Hashable {
        var name: String
        var volume: Float {
            didSet {
                player?.volume = volume
            }
        }
        var player: AVAudioPlayer?
    }
    
    @Published var tracks: [Track] = []
    @Published var isPlaying = true
    
    init() {
        let trackNames = ["piano", "bass", "vocals", "drums", "guitar", "other"]
        let initialVolumes: [Float] = [0.5, 0.7, 0.8, 0.6, 0.9, 0.4]
        
        for (index, name) in trackNames.enumerated() {
            if let player = createPlayer(for: name) {
                player.volume = initialVolumes[index]
                player.numberOfLoops = -1 // Loop indefinitely
                player.play()
                
                tracks.append(Track(name: name, volume: initialVolumes[index], player: player))
            }
        }
    }
    
    func createPlayer(for name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Audio file not found: \(name).mp3")
            return nil
        }
        
        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Failed to create audio player for \(name): \(error)")
            return nil
        }
    }
    
    func adjustVolume(for name: String, to newVolume: Float) {
        if let index = tracks.firstIndex(where: { $0.name == name }) {
            tracks[index].volume = newVolume
            tracks[index].player?.volume = newVolume
        }
    }
    
    func togglePlayPause() {
            isPlaying.toggle()
            
            if isPlaying {
                for track in tracks {
                    track.player?.play()
                }
            } else {
                for track in tracks {
                    track.player?.pause()
                }
            }
        }
}
