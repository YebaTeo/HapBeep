//
//  OnBoardingGesture.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 20/07/26.
//

import SwiftUI

struct OnBoardingGesture: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "applewatch")
                .foregroundStyle(.teal)
                .font(.largeTitle)
                .padding(10)
            
            Text("Gesture")
                .font(.body)
                .fontWeight(.semibold)
                .padding(.bottom, 2)
            
            Text("Flick your wrist to dismiss the alert and resume listening")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    OnBoardingGesture()
}
