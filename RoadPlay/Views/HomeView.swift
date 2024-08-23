//
//  HomeView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            PlayPauseButton(isPlaying: $audioManager.isPlaying) {
                audioManager.togglePlayPause()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView(audioManager: AudioManager())
}
