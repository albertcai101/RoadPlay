//
//  PlayPauseButton.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct PlayPauseButton: View {
    @Binding var isPlaying: Bool
    var action: () -> Void
    
    @State private var transparency = 0.0
    
    var body: some View {
        Button {
            action()
            transparency = 0.6
            withAnimation(.easeOut(duration: 0.2)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    transparency = 0.0
                }
            }
        } label: {
            ZStack {
                Image(systemName: "pause.fill")
                    .font(.system(size: 64))
                    .scaleEffect(isPlaying ? 1 : 0)
                    .opacity(isPlaying ? 1 : 0)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isPlaying)
                Image(systemName: "play.fill")
                    .font(.system(size: 64))
                    .scaleEffect(isPlaying ? 0 : 1)
                    .opacity(isPlaying ? 0 : 1)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isPlaying)
            }
        }
    }
}
