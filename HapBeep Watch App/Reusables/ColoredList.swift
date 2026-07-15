//
//  ColoredList.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 15/07/26.
//

import SwiftUI

struct ColoredList<Content: View>: View {
    let color: Color
    @ViewBuilder let content: Content
    
    init(
        color: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowPlatterColor(color.opacity(0.2))
    }
}

#Preview {
    ColoredList(
        color: .teal
    ) {
        Text("Hello, world")
    }
}
