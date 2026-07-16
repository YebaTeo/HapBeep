//
//  OnBoarding5View.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct OnBoardingCompletionView: View {
    @AppStorage("hasCompletedOnBoarding")
    private var hasCompletedOnBoarding: Bool = false
    
    var body: some View {
        ScrollView {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            
            VStack {
                Text("You are all set")
                    .font(.title3.bold())
                Text("HapBeeb is ready to assist you!")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Get Started") {
                    hasCompletedOnBoarding = true
                }
                .buttonStyle(.glass)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnBoardingCompletionView()
    }
}
