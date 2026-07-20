
//
//  TutorialView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct OnBoardingCompiled: View {
    @State private var selectedTab: Int = 0
    @State private var player = VocabularyPlayer()
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                OnBoarding2View()
                .tag(0)
                
                GradientBackground(color: .red) {
                    CriticalAlertInfoView()
                }
                .tag(1)
                GradientBackground(color: .orange) {
                    CautionAlertInfoView()
                }
                .tag(2)
                GradientBackground(color: .teal) {
                    InformationAlertInfoView()
                }
                .tag(3)
                
                OnBoardingGesture()
                .tag(4)
                
                OnBoardingCompletionView()
                .tag(5)
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index == selectedTab ? .white : .gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 12)
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbar(.hidden, for: .bottomBar)
        .onChange(of: selectedTab) { _, tab in
            switch tab {
            case 1: player.play(.critical)
            case 2: player.play(.caution)
            case 3: player.play(.information)
            default: player.stop()
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnBoardingCompiled()
    }
}
