
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct InformationAlertInfoView: View {
    var body: some View {
        GradientBackground(color: .teal) {
            VStack {
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
                .padding(.bottom, 16)
                
                HStack (spacing: 15) {
                    Image("IconDashboardSound")
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

