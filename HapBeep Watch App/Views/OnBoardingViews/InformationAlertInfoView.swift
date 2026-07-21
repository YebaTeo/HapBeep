
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct InformationAlertInfoView: View {
    @State private var tapCount: Int = 0
    private var dataManager = DataManager.shared
    
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
                    Button {
                        tapCount += 1
                        
                        if tapCount >= 12 {
                            dataManager.resetData()
                            tapCount = 0
                        }
                    } label: {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(.teal)
                    }
                    .buttonStyle(.plain)
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

