//
//  GameProgress.swift
//  2048
//

import Foundation

struct GameProgress: Equatable {
    let configuration: GameConfiguration
    let score: Int
    let moveCount: Int
    let highestTile: Int

    static func empty(configuration: GameConfiguration) -> GameProgress {
        GameProgress(
            configuration: configuration,
            score: 0,
            moveCount: 0,
            highestTile: 0
        )
    }
}
