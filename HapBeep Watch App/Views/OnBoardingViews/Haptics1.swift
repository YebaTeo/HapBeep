//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct Haptics1: View {
    var body: some View {
        
        VStack{
            
            VStack{
                
                Text("Critical")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                
                Text("Pull over immediately and inspect your vehicle")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            
            
            HStack (spacing: 15) {
                Image("IconMetalRattling")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                
                Image("IconSirens")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                
                Image("IconTireFlat")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
            }
            
        }
    }
}

#Preview {
    Haptics1()
}
