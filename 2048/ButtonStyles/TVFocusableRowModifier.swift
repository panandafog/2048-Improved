//
//  TVFocusableRowModifier.swift
//  2048
//

import SwiftUI

#if os(tvOS)
struct TVFocusableRowModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    let cornerRadius: CGFloat

    private var scale: CGFloat {
        isFocused ? GameButtonMetrics.focusedScale : GameButtonMetrics.defaultScale
    }

    private var borderOpacity: Double {
        isFocused ? GameButtonMetrics.focusedBorderOpacity : GameButtonMetrics.hiddenOpacity
    }

    private var borderWidth: CGFloat {
        isFocused ? GameButtonMetrics.focusedBorderWidth : GameButtonMetrics.hiddenBorderWidth
    }

    private var shadowOpacity: Double {
        isFocused ? GameButtonMetrics.focusedShadowOpacity : GameButtonMetrics.hiddenOpacity
    }

    private var shadowRadius: CGFloat {
        isFocused ? GameButtonMetrics.focusedShadowRadius : GameButtonMetrics.hiddenShadowRadius
    }

    func body(content: Content) -> some View {
        content
            .overlay(focusBorder)
            .shadow(
                color: Color.accentColor.opacity(shadowOpacity),
                radius: shadowRadius
            )
            .scaleEffect(scale)
            .focusable()
            .focused($isFocused)
            .animation(.easeOut(duration: GameButtonMetrics.animationDuration), value: isFocused)
    }

    private var focusBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                Color.accentColor.opacity(borderOpacity),
                lineWidth: borderWidth
            )
    }
}

extension View {
    func tvFocusableRow(cornerRadius: CGFloat) -> some View {
        modifier(TVFocusableRowModifier(cornerRadius: cornerRadius))
    }
}
#endif
