//
//  OnBoarding5View.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct OnBoarding5View: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            
            VStack {
                Text("You are all set")
                    .font(.title3.bold())
                Text("You can change your alert settings anytime in the app")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            .padding(.top, 16)
        }
    }
}

#Preview {
    OnBoarding5View()
}
