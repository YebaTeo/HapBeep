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
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        TextButton(text: "Start") {}
    }
    .background(.white)
}
