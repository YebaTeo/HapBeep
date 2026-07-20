//
//  OnBoardingView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct OnBoardingWelcomeView: View {
    @AppStorage("hasCompletedOnBoarding")
    private var hasCompletedOnBoarding: Bool = false
    
    var body: some View {
        GradientBackground(color: .blue) {
            VStack {
                VStack(spacing: 4) {
                    Text("HapBeep")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Hear the road through your wrist")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                
                }
                .padding(.bottom, 8)
                
                NavigationLink("Learn our haptics") {
                    OnBoardingCompiled()
                }
                .buttonStyle(.glassProminent)
                .tint(.blue)
                
                Button("Skip") {
                    hasCompletedOnBoarding = true
                }
                .buttonStyle(.glass)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnBoardingWelcomeView()
    }
}
