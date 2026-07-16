//
//  TutorialView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CriticalAlertInfoView()
                CautionAlertInfoView()
                InformationAlertInfoView()
            }
        }
        .toolbar(.hidden, for: .bottomBar)
        .navigationTitle("Alert Types")
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
