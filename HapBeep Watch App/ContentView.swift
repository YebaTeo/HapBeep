//
//  ContentView.swift
//  HapBeep Watch App
//
//  Created by Yeba Teo on 14/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to HapBeep App!")
                    .multilineTextAlignment(.center)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
