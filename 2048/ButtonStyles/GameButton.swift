//
//  GameButton.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct GameButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .font(.title2)
            .background(Color.buttonBackground)
            .foregroundColor(Color.labelLight)
            .cornerRadius(.CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
