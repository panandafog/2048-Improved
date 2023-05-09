//
//  MoveDirection.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import Foundation

enum MoveDirection {
    case up
    case down
    case left
    case right
    
    var isVertical: Bool {
        self == .up || self == .down
    }
    
    var isStraight: Bool {
        self == .up || self == .left
    }
    
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
}
