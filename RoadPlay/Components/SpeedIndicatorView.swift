//
//  SpeedLimitView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct SpeedIndicatorView: View {
    let speed: Double
    
    var body: some View {
        VStack {
            Text(String(format: "%.0f", speed))
                .font(.largeTitle)
                .bold()
            
            Text("mph")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
        }
        .frame(width: 76, height: 92)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

#Preview {
    SpeedIndicatorView(speed: 20)
}
