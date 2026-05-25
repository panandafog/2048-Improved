//
//  GameButtonMetrics.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import Foundation
import SwiftUI

enum GameButtonMetrics {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 12
    static let tvMenuWidth: CGFloat = 460
    
    static let defaultScale: CGFloat = 1
    static let pressedScale: CGFloat = 0.96
    
    static let enabledOpacity: Double = 1
    static let disabledOpacity: Double = 0.45
    static let hiddenOpacity: Double = 0
    
    static let focusedBorderOpacity: Double = 0.95
    static let hiddenBorderWidth: CGFloat = 0
    
    static let focusedShadowOpacity: Double = 0.45
    static let hiddenShadowRadius: CGFloat = 0
    
    static let animationDuration: Double = 0.2
    
#if os(tvOS)
    static let focusedScale: CGFloat = 1.08
    static let focusedBorderWidth: CGFloat = 4
    static let focusedShadowRadius: CGFloat = 20
#else
    static let focusedScale: CGFloat = 1.04
    static let focusedBorderWidth: CGFloat = 3
    static let focusedShadowRadius: CGFloat = 12
#endif
}
