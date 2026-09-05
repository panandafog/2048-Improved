//
//  Challenge.swift
//  2048
//

import Foundation

struct Challenge: Identifiable, Equatable {
    // These IDs can later be reused as Game Center achievement identifiers.
    let id: String
    let titleKey: String
    let descriptionKey: String
    let condition: ChallengeCondition

    var title: String {
        titleKey.localized
    }

    var description: String {
        descriptionKey.localized
    }
}

enum ChallengeCondition: Equatable {
    case moveCount(Int)
    case score(Int)
    case highestTile(Int)
    case highestTileWithinMoves(tile: Int, moves: Int)

    func isSatisfied(by progress: GameProgress) -> Bool {
        switch self {
        case .moveCount(let target):
            return progress.moveCount >= target
        case .score(let target):
            return progress.score >= target
        case .highestTile(let target):
            return progress.highestTile >= target
        case .highestTileWithinMoves(let tile, let moves):
            return progress.highestTile >= tile && progress.moveCount <= moves
        }
    }
}

enum ChallengeCatalog {
    static let all: [Challenge] = [
        Challenge(
            id: "challenge.first_move",
            titleKey: "Challenge.FirstMove.Title",
            descriptionKey: "Challenge.FirstMove.Description",
            condition: .moveCount(1)
        ),
        Challenge(
            id: "challenge.score_100",
            titleKey: "Challenge.Score100.Title",
            descriptionKey: "Challenge.Score100.Description",
            condition: .score(100)
        ),
        Challenge(
            id: "challenge.tile_64",
            titleKey: "Challenge.Tile64.Title",
            descriptionKey: "Challenge.Tile64.Description",
            condition: .highestTile(64)
        ),
        Challenge(
            id: "challenge.tile_64_in_35_moves",
            titleKey: "Challenge.Tile64Quick.Title",
            descriptionKey: "Challenge.Tile64Quick.Description",
            condition: .highestTileWithinMoves(tile: 64, moves: 35)
        ),
        Challenge(
            id: "challenge.score_500",
            titleKey: "Challenge.Score500.Title",
            descriptionKey: "Challenge.Score500.Description",
            condition: .score(500)
        ),
        Challenge(
            id: "challenge.tile_128",
            titleKey: "Challenge.Tile128.Title",
            descriptionKey: "Challenge.Tile128.Description",
            condition: .highestTile(128)
        ),
        Challenge(
            id: "challenge.tile_128_in_70_moves",
            titleKey: "Challenge.Tile128Quick.Title",
            descriptionKey: "Challenge.Tile128Quick.Description",
            condition: .highestTileWithinMoves(tile: 128, moves: 70)
        ),
        Challenge(
            id: "challenge.score_2000",
            titleKey: "Challenge.Score2000.Title",
            descriptionKey: "Challenge.Score2000.Description",
            condition: .score(2_000)
        ),
        Challenge(
            id: "challenge.tile_256",
            titleKey: "Challenge.Tile256.Title",
            descriptionKey: "Challenge.Tile256.Description",
            condition: .highestTile(256)
        ),
        Challenge(
            id: "challenge.tile_256_in_140_moves",
            titleKey: "Challenge.Tile256Quick.Title",
            descriptionKey: "Challenge.Tile256Quick.Description",
            condition: .highestTileWithinMoves(tile: 256, moves: 140)
        ),
        Challenge(
            id: "challenge.tile_512",
            titleKey: "Challenge.Tile512.Title",
            descriptionKey: "Challenge.Tile512.Description",
            condition: .highestTile(512)
        ),
        Challenge(
            id: "challenge.score_5000",
            titleKey: "Challenge.Score5000.Title",
            descriptionKey: "Challenge.Score5000.Description",
            condition: .score(5_000)
        ),
        Challenge(
            id: "challenge.moves_500",
            titleKey: "Challenge.Moves500.Title",
            descriptionKey: "Challenge.Moves500.Description",
            condition: .moveCount(500)
        ),
        Challenge(
            id: "challenge.tile_1024",
            titleKey: "Challenge.Tile1024.Title",
            descriptionKey: "Challenge.Tile1024.Description",
            condition: .highestTile(1_024)
        ),
        Challenge(
            id: "challenge.score_10000",
            titleKey: "Challenge.Score10000.Title",
            descriptionKey: "Challenge.Score10000.Description",
            condition: .score(10_000)
        ),
        Challenge(
            id: "challenge.tile_2048",
            titleKey: "Challenge.Tile2048.Title",
            descriptionKey: "Challenge.Tile2048.Description",
            condition: .highestTile(2_048)
        )
    ]
}
