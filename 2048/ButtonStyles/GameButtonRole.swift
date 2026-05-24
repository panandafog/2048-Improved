//
//  GameButtonRole.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

enum GameButtonRole {
    case primary
    case secondary
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .buttonBackgroundPrimary
        case .secondary:
            return .buttonBackgroundSecondary
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .labelLight
        case .secondary:
            return .labelDark
        }
    }
}
