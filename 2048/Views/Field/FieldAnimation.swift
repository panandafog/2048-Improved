//
//  FieldAnimation.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import Foundation
import SwiftUI

enum FieldAnimation {
    // MARK: - Durations
    
    static let moveDuration: TimeInterval = 0.18
    static let mergeDuration: TimeInterval = 0.14
    static let appearanceDuration: TimeInterval = 0.14
    
    // MARK: - Opacity
    
    static let hiddenOpacity: Double = 0
    static let visibleOpacity: Double = 1
    
    // MARK: - Animations
    
    static let move = Animation.easeOut(duration: moveDuration)
    static let merge = Animation.easeOut(duration: mergeDuration)
    static let appearance = Animation.easeOut(duration: appearanceDuration)
}
