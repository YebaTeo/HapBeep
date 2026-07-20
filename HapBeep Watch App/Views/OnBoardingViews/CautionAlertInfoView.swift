
//
//  Haptics1.swift
//  HapBeep Watch App
//
//  Created by Michelle Intan Handa on 15/07/26.
//

import SwiftUI

struct CautionAlertInfoView: View {
    var body: some View {
        VStack {
            VStack{
                Text("Caution")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                Text("Be alert and prepare to react")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 10)
            
            HStack (spacing: 12) {
                Image(systemName: "horn.blast")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Image(systemName: "car.2.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Image(systemName: "car.rear.and.tire.marks")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CautionAlertInfoView()
    }
}
