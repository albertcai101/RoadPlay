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
    @StateObject private var motionManager = MotionManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        VStack {
            // Telemetry for Sensor Readouts
            HStack {
                VStack {
                    Text("w")
                        .font(.caption)
                    Text("\(motionManager.angleVelZ.last ?? 0.0, specifier: "%.1f") rad/s")
                        .font(.headline)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("a")
                        .font(.caption)
                    Text("\(motionManager.accelZ.last ?? 0.0, specifier: "%.1f") g")
                        .font(.headline)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack {
                    Text("s")
                        .font(.caption)
                    Text("\(locationManager.speed.last ?? 0.0, specifier: "%.1f") mph")
                        .font(.headline)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Play/Pause Button
            Button(action: {
                audioManager.togglePlayPause()
            }) {
                Text(audioManager.isPlaying ? "Pause" : "Play")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom)
            
            // Audio Sliders
            VStack {
                ForEach($audioManager.tracks, id: \.name) { $track in
                    VStack(alignment: .leading) {
                        Text("\(track.name.capitalized): \(String(format: "%.2f", track.volume))")
                            .font(.headline)
                        
                        Slider(
                            value: $track.volume,
                            in: 0...1
                        )
                        .accentColor(.green)
                    }
                    .padding(.horizontal)
                }            }
            .padding(.bottom)

            // ScrollView for the charts
            ScrollView {
                VStack {
                    // Angular Velocity about the Vertical Axis (Z-Axis)
                    Chart {
                        ForEach(Array(motionManager.angleVelZ.enumerated()), id: \.offset) { index, value in
                            LineMark(x: .value("Time", index), y: .value("Angular Velocity Z", value))
                                .foregroundStyle(.yellow)
                                .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYScale(domain: -10...10)
                    .frame(height: 300)
                    .padding()
                    
                    // Acceleration In and Out of the Screen (Z-Axis)
                    Chart {
                        ForEach(Array(motionManager.accelZ.enumerated()), id: \.offset) { index, value in
                            LineMark(x: .value("Time", index), y: .value("Acceleration Z", value))
                                .foregroundStyle(.pink)
                                .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYScale(domain: -3...3)
                    .frame(height: 300)
                    .padding()
                    
                    // Speed Chart
                    Chart {
                        ForEach(Array(locationManager.speed.enumerated()), id: \.offset) { index, value in
                            LineMark(x: .value("Time", index), y: .value("Speed", value))
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYScale(domain: 0...30) // Adjust domain based on expected speed range
                    .frame(height: 300)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
