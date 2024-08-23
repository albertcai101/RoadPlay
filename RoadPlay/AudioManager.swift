//
//  AudioManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/22/24.
//

import AVFoundation
import MediaPlayer
import SwiftUI

class AudioManager: ObservableObject {
    struct Track: Hashable {
        var name: String
        var volume: Float {
            didSet {
                player?.volume = volume
            }
        }
        var pan: Float { // -1.0 is full left, 0.0 is center, and +1.0 is full right
            didSet {
                player?.pan = pan
            }
        }
        var player: AVAudioPlayer?
    }
    
    @Published var tracks: [Track] = []
    @Published var isPlaying = true
    
    init() {
        configureNowPlaying()
        configureRemoteCommandCenter()
        
        let trackNames = ["piano", "bass", "vocals", "drums", "guitar", "other"]
        let initialVolumes: [Float] = [0.5, 0.7, 0.8, 0.6, 0.9, 0.4]
        let initialPans: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        for (index, name) in trackNames.enumerated() {
            if let player = createPlayer(for: name) {
                player.volume = initialVolumes[index]
                player.pan = initialPans[index]
                player.numberOfLoops = -1 // Loop indefinitely
                player.play()
                
                let track = Track(name: name, volume: initialVolumes[index], pan: initialPans[index], player: player)
                tracks.append(track)
            }
        }
        
        updateNowPlayingInfo()
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
            updateNowPlayingInfo()
        }
    }
    
    func adjsutPan(for name: String, to newPan: Float) {
        if let index = tracks.firstIndex(where: { $0.name == name }) {
            tracks[index].pan = newPan
            tracks[index].player?.pan = newPan
            updateNowPlayingInfo()
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
        
        updateNowPlayingInfo()
    }
    
    private func configureNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Live Session"
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Assuming we're using the first track as a representative title/artist
        if let firstTrack = tracks.first {
            nowPlayingInfo[MPMediaItemPropertyTitle] = "Roadplay Session"
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func configureRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.isPlaying {
                self.togglePlayPause()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.togglePlayPause()
                return .success
            }
            return .commandFailed
        }
        
        // Additional controls can be configured similarly:
        // commandCenter.skipForwardCommand, commandCenter.skipBackwardCommand, etc.
    }
}
