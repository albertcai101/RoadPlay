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
    @ObservedObject private var motionManager: MotionManager
    @ObservedObject private var locationManager: LocationManager
    
    // Navigation States
    @State private var selectedTab : Int = 0
    @State private var isDrawerOpen : Bool = false
    
    init() {
        let motionManager = MotionManager()
        let locationManager = LocationManager()
        let audioManager = AudioManager()
        _dynamicMusicLoopController = StateObject(wrappedValue: DynamicMusicLoopController(motionManager: motionManager, locationManager: locationManager, audioManager: audioManager))
        _audioManager = ObservedObject(wrappedValue: audioManager)
        _motionManager = ObservedObject(wrappedValue: motionManager)
        _locationManager = ObservedObject(wrappedValue: locationManager)
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab ) {
                HomeView(audioManager: audioManager, locationManager: locationManager)
                    .tabItem {
                        Image(systemName: "car.side.fill")
                        Text("Drive")
                    }
                    .tag(0)
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)
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

#Preview {
    ContentView()
}
