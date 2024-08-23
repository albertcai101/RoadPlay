//
//  SideDrawerView.swift
//  RoadPlay
//
//  Created by Albert Cai on 8/23/24.
//

import SwiftUI

struct SideDrawerView<Content: View>: View {
    @Binding var isOpen: Bool
    let content: Content
    
    init(isOpen: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isOpen = isOpen
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isOpen.toggle()
                    }
                
                HStack {
                    VStack {
                        content
                    }
                    .frame(width: 250)
                    .background(Color.white)
                    .transition(.move(edge: .leading))
                    
                    Spacer()
                }
            }
        }
        .animation(.default, value: isOpen)
    }
}
#Preview {
    SideDrawerView(isOpen: .constant(true)) {
        Text("Hello, World!")
    }
}
