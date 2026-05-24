//
//  GameButtonBody.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

struct GameButtonBody<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    
    let label: Label
    let isPressed: Bool
    let role: GameButtonRole
    let layout: GameButtonLayout
    
    private var isHighlighted: Bool {
        isEnabled && isFocused
    }
    
    private var scale: CGFloat {
        if isPressed {
            return GameButtonMetrics.pressedScale
        }
        
        return isHighlighted ? GameButtonMetrics.focusedScale : GameButtonMetrics.defaultScale
    }
    
    private var borderOpacity: Double {
        isHighlighted ? GameButtonMetrics.focusedBorderOpacity : GameButtonMetrics.hiddenOpacity
    }
    
    private var borderWidth: CGFloat {
        isHighlighted ? GameButtonMetrics.focusedBorderWidth : GameButtonMetrics.hiddenBorderWidth
    }
    
    private var shadowOpacity: Double {
        isHighlighted ? GameButtonMetrics.focusedShadowOpacity : GameButtonMetrics.hiddenOpacity
    }
    
    private var shadowRadius: CGFloat {
        isHighlighted ? GameButtonMetrics.focusedShadowRadius : GameButtonMetrics.hiddenShadowRadius
    }
    
    private var opacity: Double {
        isEnabled ? GameButtonMetrics.enabledOpacity : GameButtonMetrics.disabledOpacity
    }
    
    private var animation: Animation {
        .easeOut(duration: GameButtonMetrics.animationDuration)
    }
    
    var body: some View {
        label
            .font(.title2)
            .foregroundColor(role.foregroundColor)
            .frame(width: layout.width)
            .padding(.vertical, GameButtonMetrics.verticalPadding)
            .padding(.horizontal, GameButtonMetrics.horizontalPadding)
            .background(background)
            .overlay(focusBorder)
            .shadow(
                color: Color.accentColor.opacity(shadowOpacity),
                radius: shadowRadius
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .contentShape(RoundedRectangle(cornerRadius: .CornerRadius.button, style: .continuous))
            .animation(animation, value: isPressed)
            .animation(animation, value: isFocused)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: .CornerRadius.button, style: .continuous)
            .fill(role.backgroundColor)
    }
    
    private var focusBorder: some View {
        RoundedRectangle(cornerRadius: .CornerRadius.button, style: .continuous)
            .strokeBorder(
                Color.accentColor.opacity(borderOpacity),
                lineWidth: borderWidth
            )
    }
}
