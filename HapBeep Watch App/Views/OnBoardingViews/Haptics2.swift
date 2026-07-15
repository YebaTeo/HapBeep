
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct Haptics2: View {
    var body: some View {
        VStack{
            Text("Caution")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
            
            Text("Check your mirrors to see what's happening around your car")
                .font(.caption)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 10)
        
        HStack (spacing: 15) {
            Image("IconHonkCar")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
            
            Image("IconHonkMotorcycle")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
            
            Image("IconTireScreeching")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
        }
        
    }
}

#Preview {
    Haptics2()
}
