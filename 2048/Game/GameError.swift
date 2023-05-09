//
//  GameError.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import Foundation

enum GameError: Error {
    case noFreeSpace
    case cantMove
}
