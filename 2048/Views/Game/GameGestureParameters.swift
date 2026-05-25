//
//  GameGestureParameters.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

enum GameGestureParameters {
    // MARK: - Drag Gesture
    
    static let dragMinimumDistance: CGFloat = 20
    static let dragCoordinateSpace: CoordinateSpace = .global
    
    // MARK: - Trackpad Gesture
    
    static let trackpadSwipeMinimumDistance: CGFloat = 30
    static let trackpadSwipeResetInterval: TimeInterval = 0.25
    
    // MARK: - Angle Conversion
    
    static let dragAngleOffsetRadians = CGFloat.pi / 2
    static let degreesPerRadian = CGFloat(180.0) / CGFloat.pi
    static let fullCircleDegrees: CGFloat = 360
}
