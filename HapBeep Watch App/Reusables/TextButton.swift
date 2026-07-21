//
//  IconButton.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 14/07/26.
//

import SwiftUI

struct TextButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear, in: Capsule())
    }
}

#Preview {
    TextButton(text: "Start") {}
}
