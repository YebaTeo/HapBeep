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
            VStack(spacing: 32) {
                CriticalAlertInfoView()
                CautionAlertInfoView()
                InformationAlertInfoView()
            }
        }
        .toolbar(.hidden, for: .bottomBar)
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
