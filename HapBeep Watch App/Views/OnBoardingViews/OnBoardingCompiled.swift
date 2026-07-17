
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
            OnBoardingCompletionView()
                .tag(4)
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
