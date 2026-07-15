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
                Image("HapBeep")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                
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
    OnBoarding1View()
}
