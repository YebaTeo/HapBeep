//
//  SettingsView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 14/07/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode( .inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
