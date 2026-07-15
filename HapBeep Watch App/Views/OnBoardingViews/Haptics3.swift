
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct Haptics3: View {
    var body: some View {
        VStack{
            Text("Information")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.mint)
            
            Text("Check your dashboard for system alerts")
                .font(.caption)
                .foregroundStyle(.mint)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        
        HStack (spacing: 15) {
            Image("IconHonkCar")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
            
            Image("IconKnocking")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
            
            Image("IconEngine")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
        }
        
    }
}

#Preview {
    Haptics3()
}

