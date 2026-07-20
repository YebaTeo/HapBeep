
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct InformationAlertInfoView: View {
    private var icons: [String] = [
        "car.top.radiowaves.rear",
        "car.window.right.exclamationmark"
    ]
    
    var body: some View {
        VStack {
            VStack{
                Text("Information")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.teal)
                
                Text("General sounds that may be useful to notice")
                    .font(.caption)
                    .foregroundStyle(.teal)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 16)
            
            HStack (spacing: 12) {
                ForEach(icons, id: \.description) { icon in
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.teal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        InformationAlertInfoView()
    }
}

