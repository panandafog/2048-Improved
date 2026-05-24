//
//  GameButtonLayout.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

enum GameButtonLayout {
    case standard
    case tvMenu
    
    var width: CGFloat? {
        switch self {
        case .standard:
            return nil
        case .tvMenu:
            return GameButtonMetrics.tvMenuWidth
        }
    }
}
