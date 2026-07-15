
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct Haptics2: View {
    var body: some View {
        VStack {
            VStack{
                Text("Caution")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                Text("Check your mirrors to see what's happening around")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 16)
            
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
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                NavigationLink("Continue") {
                    Haptics3()
                }
                .buttonStyle(.glass)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Haptics2()
    }
}
