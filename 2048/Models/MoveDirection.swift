//
//  MoveDirection.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import CoreGraphics
import Foundation

enum MoveDirection {
    // MARK: - Cases
    
    case up
    case down
    case left
    case right
    
    // MARK: - Axis Properties
    
    var isVertical: Bool {
        self == .up || self == .down
    }
    
    var isStraight: Bool {
        self == .up || self == .left
    }
    
    // MARK: - Keyboard Mapping
    
    init?(keyCode: UInt16) {
        switch keyCode {
        case 126:
            self = .up
        case 125:
            self = .down
        case 123:
            self = .left
        case 124:
            self = .right
        default:
            return nil
        }
    }
    
    // MARK: - Angle Mapping
    
    init?(degrees: Double) {
        switch degrees {
        case 305 ... 365:
            fallthrough
        case 0 ..< 45:
            self = .right
        case 45 ..< 135:
            self = .up
        case 135 ..< 225:
            self = .left
        case 225 ..< 305:
            self = .down
        default:
            return nil
        }
    }
    
    // MARK: - Swipe Mapping
    
    init?(swipeDeltaX: CGFloat, deltaY: CGFloat) {
        guard abs(swipeDeltaX) > 0 || abs(deltaY) > 0 else {
            return nil
        }
        
        if abs(swipeDeltaX) > abs(deltaY) {
            self = swipeDeltaX < 0 ? .right : .left
        } else {
            self = deltaY > 0 ? .up : .down
        }
    }
    
    init?(trackpadSwipeDelta: CGSize, minimumDistance: CGFloat) {
        let maxDelta = max(abs(trackpadSwipeDelta.width), abs(trackpadSwipeDelta.height))
        guard maxDelta >= minimumDistance else {
            return nil
        }
        
        self.init(
            swipeDeltaX: trackpadSwipeDelta.width,
            deltaY: trackpadSwipeDelta.height
        )
    }
}
