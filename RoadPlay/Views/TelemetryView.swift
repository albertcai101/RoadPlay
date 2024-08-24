//
//  TelemetryView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI
import Charts

struct TelemetryView: View {
    
    @ObservedObject var motionManager: MotionManager
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            HStack {
                SpeedIndicatorView(speed: locationManager.speed.last ?? 0.0)
                PanIndicatorView(pan: Double(audioManager.tracks.last?.pan ?? 0.0))
            }
            .padding(.top, 20)
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
                        if let lastIndex = motionManager.angleVelZ.indices.last {
                            let lastValue = motionManager.angleVelZ[lastIndex]
                            PointMark(x: .value("Time", lastIndex), y: .value("Angular Velocity Z", lastValue))
                                .foregroundStyle(Color.yellow)
                                .annotation(position: .top) {
                                    Text("\(lastValue, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                }
                            
                            let lastValueSmoothed = motionManager.smoothAngleVelZ
                            PointMark(x: .value("Time", lastIndex), y: .value("Angular Velocity Z", lastValueSmoothed))
                                .foregroundStyle(Color.orange)
                                .annotation(position: .bottom) {
                                    Text("\(lastValueSmoothed, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                        }
                    }
                    .chartYAxisLabel("Angular Velocity (rad/s)")
                    .chartYScale(domain: -1.5...1.5)
                    .frame(height: 150)
                    .padding()
                    
                    // Acceleration In and Out of the Screen (Z-Axis)
                    Chart {
                        ForEach(Array(motionManager.accelZ.enumerated()), id: \.offset) { index, value in
                            LineMark(x: .value("Time", index), y: .value("Acceleration Z", value))
                                .foregroundStyle(.pink)
                                .interpolationMethod(.catmullRom)
                        }
                        if let lastIndex = motionManager.accelZ.indices.last {
                            let lastValue = motionManager.accelZ[lastIndex]
                            PointMark(x: .value("Time", lastIndex), y: .value("Acceleration Z", lastValue))
                                .foregroundStyle(Color.pink)
                                .annotation(position: .top) {
                                    Text("\(lastValue, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.pink)
                                }
                        }
                    }
                    .chartYAxisLabel("Acceleration (g)")
                    .chartYScale(domain: -0.5...0.5)
                    .frame(height: 150)
                    .padding()
                    
                    // Speed Chart
                    Chart {
                        ForEach(Array(locationManager.speed.enumerated()), id: \.offset) { index, value in
                            LineMark(x: .value("Time", index), y: .value("Speed", value))
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)
                        }
                        if let lastIndex = locationManager.speed.indices.last {
                            let lastValue = locationManager.speed[lastIndex]
                            PointMark(x: .value("Time", lastIndex), y: .value("Speed", lastValue))
                                .foregroundStyle(Color.blue)
                                .annotation(position: .top) {
                                    Text("\(lastValue, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                        }
                    }
                    .chartYAxisLabel("Speed (MPH)")
                    .chartYScale(domain: 0...30) // Adjust domain based on expected speed range
                    .frame(height: 150)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    TelemetryView(motionManager: .init(), locationManager: .init(), audioManager: .init())
}
