
//
//  TutorialView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct OnBoardingCompiled: View {
    var body: some View {
        TabView {
            
            OnBoarding2View()
            
            GradientBackground(color: .red) {
                CriticalAlertInfoView()
            }
                
            GradientBackground(color: .orange) {
                CautionAlertInfoView()
            }
                
            GradientBackground(color: .teal) {
                InformationAlertInfoView()
            }
            
            OnBoardingCompletionView()
        }
        .toolbar(.hidden, for: .bottomBar)
    }
}

#Preview {
    NavigationStack {
        OnBoardingCompiled()
    }
}
