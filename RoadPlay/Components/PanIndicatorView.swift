//
//  SwayView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct PanIndicatorView: View {
    let pan: Double // should be between -1.0 and 1.0
    
    var body: some View {
        VStack {
            Text(String(format: "%.1f", pan))
                .font(.largeTitle)
                .bold()
            
            Text("L/R")
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
    PanIndicatorView(pan: 20)
}
