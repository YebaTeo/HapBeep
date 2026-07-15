//
//  OnBoardingView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct OnBoardingView: View {
    @State private var currentPage: Int = 2
    
    var body: some View {
        ScrollView {
            VStack {
                if currentPage == 0 {
                    OnBoarding1View()
                } else if currentPage == 1 {
                    OnBoarding2View()
                } else if currentPage == 2 {
                    OnBoarding3View()
                } else if currentPage == 3 {
                    OnBoarding4View()
                } else if currentPage == 4 {
                    OnBoarding5View()
                }
            }
            .padding(.bottom, 16)
            
            Spacer()
            
            
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Continue") {
                    if currentPage == 4 {
                        currentPage = 0
                    } else {
                        currentPage += 1
                    }
                }
                .buttonStyle(.glass)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnBoardingView()
    }
}
