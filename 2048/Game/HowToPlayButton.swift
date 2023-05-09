//
//  HowToPlayButton.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct HowToPlayButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .cornerRadius(.CornerRadius.button)
            .padding()
            .font(.title2)
            .foregroundColor(Color.labelDark)
            .cornerRadius(.CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
