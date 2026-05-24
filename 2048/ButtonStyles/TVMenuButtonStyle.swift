//
//  TVMenuButtonStyle.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

#if os(tvOS)
struct TVMenuButtonStyle: ButtonStyle {
    let role: GameButtonRole
    
    init(role: GameButtonRole = .primary) {
        self.role = role
    }
    
    func makeBody(configuration: Configuration) -> some View {
        GameButtonBody(
            label: configuration.label,
            isPressed: configuration.isPressed,
            role: role,
            layout: .tvMenu
        )
    }
}
#endif
