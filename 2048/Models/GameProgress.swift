//
//  GameProgress.swift
//  2048
//

import Foundation

struct GameProgress: Equatable {
    let score: Int
    let moveCount: Int
    let highestTile: Int

    static let empty = GameProgress(score: 0, moveCount: 0, highestTile: 0)
}
