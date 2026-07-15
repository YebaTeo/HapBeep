//
//  OnBoarding1View.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import Foundation
import SwiftUI

struct OnBoarding3View: View {
    

    var body: some View {
        
        VStack {
            Text("HapBeep")
                .font(.body)
                .fontWeight(.semibold)
            
            Text("Hear the road through your wrist.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnBoarding3View()
}
