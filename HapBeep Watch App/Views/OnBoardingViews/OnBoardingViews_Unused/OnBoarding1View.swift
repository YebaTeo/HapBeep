//
//  OnBoarding1View.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import Foundation
import SwiftUI

struct OnBoarding1View: View {
    

    var body: some View {
        
            VStack {
                Text("HapBeep")
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text("Hear the road through your wrist")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            
        }
            .padding(10)
        
        VStack {
            Spacer()
            
            Button("Learn our haptics") {}
                .buttonStyle(.glassProminent)
                .tint(.accentColor)
            
            Button("Skip") {}
                .buttonStyle(.glass)
        }
        
        
    }
}

#Preview {
    OnBoarding1View()
}
