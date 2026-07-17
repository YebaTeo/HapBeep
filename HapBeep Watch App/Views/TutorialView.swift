//
//  TutorialView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        TabView {
            OnBoarding2View()
            
            CriticalAlertInfoView()
                
            CautionAlertInfoView()
                
            InformationAlertInfoView()
        }
        .toolbar(.hidden, for: .bottomBar)
        .navigationTitle("About Us")
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
