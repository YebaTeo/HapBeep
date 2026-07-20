//
//  OnBoarding1View.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import Foundation
import SwiftUI

struct OnBoarding2View: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "waveform")
                .foregroundStyle(.teal)
                .font(.largeTitle)
                .padding(10)
            
            Text("Sound to Haptics")
                .font(.body)
                .fontWeight(.semibold)
                .padding(.bottom, 2)
            
            Text("HapBeep listens to your surroundings and convert sounds into vibrations.")
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
    OnBoarding2View()
}
