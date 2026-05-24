//
//  TVMenuButtonStyle.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

#if os(tvOS)
struct TVMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        TVMenuButton(configuration: configuration)
    }
}

private struct TVMenuButton: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    
    let configuration: TVMenuButtonStyle.Configuration
    
    private var isHighlighted: Bool {
        isEnabled && isFocused
    }
    
    private var scale: CGFloat {
        if configuration.isPressed {
            return TVMenuButtonMetrics.pressedScale
        }
        
        return isHighlighted ? TVMenuButtonMetrics.focusedScale : TVMenuButtonMetrics.defaultScale
    }
    
    private var borderOpacity: Double {
        isHighlighted ? TVMenuButtonMetrics.focusedBorderOpacity : TVMenuButtonMetrics.hiddenOpacity
    }
    
    private var borderWidth: CGFloat {
        isHighlighted ? TVMenuButtonMetrics.focusedBorderWidth : TVMenuButtonMetrics.hiddenBorderWidth
    }
    
    private var shadowOpacity: Double {
        isHighlighted ? TVMenuButtonMetrics.focusedShadowOpacity : TVMenuButtonMetrics.hiddenOpacity
    }
    
    private var shadowRadius: CGFloat {
        isHighlighted ? TVMenuButtonMetrics.focusedShadowRadius : TVMenuButtonMetrics.hiddenShadowRadius
    }
    
    private var buttonOpacity: Double {
        isEnabled ? TVMenuButtonMetrics.enabledOpacity : TVMenuButtonMetrics.disabledOpacity
    }
    
    private var buttonAnimation: Animation {
        .easeOut(duration: TVMenuButtonMetrics.animationDuration)
    }
    
    var body: some View {
        configuration.label
            .font(.title2)
            .foregroundColor(.labelLight)
            .frame(width: TVMenuButtonMetrics.width)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: .CornerRadius.button, style: .continuous)
                    .fill(Color.buttonBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .CornerRadius.button, style: .continuous)
                    .strokeBorder(
                        Color.labelLight.opacity(borderOpacity),
                        lineWidth: borderWidth
                    )
            )
            .shadow(
                color: Color.labelLight.opacity(shadowOpacity),
                radius: shadowRadius
            )
            .scaleEffect(scale)
            .opacity(buttonOpacity)
            .animation(buttonAnimation, value: configuration.isPressed)
            .animation(buttonAnimation, value: isFocused)
    }
}

private enum TVMenuButtonMetrics {
    static let width: CGFloat = 460
    
    static let defaultScale: CGFloat = 1
    static let focusedScale: CGFloat = 1.08
    static let pressedScale: CGFloat = 0.96
    
    static let enabledOpacity: Double = 1
    static let disabledOpacity: Double = 0.45
    static let hiddenOpacity: Double = 0
    
    static let focusedBorderOpacity: Double = 0.95
    static let focusedBorderWidth: CGFloat = 4
    static let hiddenBorderWidth: CGFloat = 0
    
    static let focusedShadowOpacity: Double = 0.45
    static let focusedShadowRadius: CGFloat = 20
    static let hiddenShadowRadius: CGFloat = 0
    
    static let animationDuration: Double = 0.2
}
#endif
