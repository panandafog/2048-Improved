//
//  HowToPlayButton.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct HowToPlayButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GameButtonBody(
            label: configuration.label,
            isPressed: configuration.isPressed,
            role: .secondary,
            layout: .standard
        )
    }
}
