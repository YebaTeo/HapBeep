
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct InformationAlertInfoView: View {
    var body: some View {
        ScrollView {
            VStack {
                VStack{
                    Text("Information")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.teal)
                    
                    Text("Check your dashboard for system alerts")
                        .font(.caption)
                        .foregroundStyle(.teal)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 16)
                
                HStack (spacing: 15) {
                    Image(systemName: "car.top.radiowaves.rear")
                        .font(.title2)
                        .foregroundStyle(.teal)
                    
                    Image(systemName: "car.window.right.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(.teal)
                }
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                NavigationLink("Continue") {
                    OnBoardingCompletionView()
                }
                .buttonStyle(.glass)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InformationAlertInfoView()
    }
}

