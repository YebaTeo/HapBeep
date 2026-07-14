//
//  SettingsView.swift
//  HapBeep Watch App
//
//  Created by Michael Geraldi on 14/07/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(sort: \Category.severity) var categories: [Category]
    
    var body: some View {
        VStack {
            List {
                ForEach(categories) { category in
                    NavigationLink {
                        Text(category.name)
                    } label: {
                        HStack {
                            Text(category.name)
                            Spacer()
                            Text("Haptic 1")
                                .font(.system(.caption))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode( .inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(SampleData.shared.container)
    }
}
