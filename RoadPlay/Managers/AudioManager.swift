//
//  AudioManager.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/22/24.
//

import AVFoundation
import MediaPlayer
import Combine

protocol AudioManagerProtocol: AnyObject {
    var isPlaying: Bool { get }
    var tracks: [AudioManager.Track] { get }
    func togglePlayPause()
    func adjustVolume(for name: String, to newVolume: Float)
    func adjustPan(for name: String, to newPan: Float)
    func adjustPanForAllTracks(to newPan: Float)
}

class AudioManager: ObservableObject, AudioManagerProtocol {
    class Track: ObservableObject, Identifiable, Hashable {
        let id = UUID()
        @Published var name: String
        @Published var volume: Float {
            didSet {
                player?.volume = volume
            }
        }
        @Published var pan: Float {
            didSet {
                player?.pan = pan
            }
        }
        var player: AVAudioPlayer?
        
        init(name: String, volume: Float, pan: Float, player: AVAudioPlayer?) {
            self.name = name
            self.volume = volume
            self.pan = pan
            self.player = player
        }
        
        static func == (lhs: Track, rhs: Track) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    @Published var tracks: [Track] = []
    @Published var isPlaying = false
    
    init() {
        loadTracks()
        configureNowPlaying()
        configureRemoteCommandCenter()
        
        
        updateNowPlayingInfo()
    }
    
    private func loadTracks() {
        let trackNames = ["piano", "bass", "vocals", "drums", "guitar", "other"]
        let initialVolumes: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
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
        
        isPlaying = true
    }
    
    private func createPlayer(for name: String) -> AVAudioPlayer? {
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
            updateNowPlayingInfo()
        }
    }
    
    func adjustPan(for name: String, to newPan: Float) {
        if let index = tracks.firstIndex(where: { $0.name == name }) {
            tracks[index].pan = newPan
            updateNowPlayingInfo()
        }
    }
    
    func adjustPanForAllTracks(to newPan: Float) {
        for (index, track) in tracks.enumerated() {
            tracks[index].pan = newPan
        }
        updateNowPlayingInfo()
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
