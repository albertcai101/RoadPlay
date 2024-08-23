//
//  TelemetryView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct TelemetryView: View {
    
    @ObservedObject var motionManager: MotionManager
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        Text("Coming soon!")
    }
}

#Preview {
    TelemetryView(motionManager: .init(), locationManager: .init())
}
