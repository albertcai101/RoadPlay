//
//  HomeView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack {
            PlayPauseButton(isPlaying: $audioManager.isPlaying) {
                audioManager.togglePlayPause()
            }
            .padding()
            
            SpeedLimitView(speed: locationManager.speed.last ?? 0.0)
                .padding(.top, 20)
        }
    }
}

#Preview {
    HomeView(audioManager: AudioManager(), locationManager: LocationManager())
}
