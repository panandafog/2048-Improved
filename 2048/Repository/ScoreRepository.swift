//
//  ScoreRepository.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import Foundation

enum ScoreRepository {
    // MARK: - Storage
    
    private static let defaults = UserDefaults.standard
    private static let classicBestScoreKey = "BestScore"
    private static let anomalyBestScoreKey = "BestScore.Anomaly"
    
    // MARK: - Accessors
    
    static func bestScore(for configuration: GameConfiguration) -> Int {
        defaults.integer(forKey: key(for: configuration))
    }

    static func setBestScore(_ score: Int, for configuration: GameConfiguration) {
        defaults.setValue(score, forKey: key(for: configuration))
    }

    private static func key(for configuration: GameConfiguration) -> String {
        switch (configuration.mode, configuration.boardSize) {
        case (.classic, .standard):
            return classicBestScoreKey
        case (.anomaly, .standard):
            return anomalyBestScoreKey
        default:
            return "BestScore.\(configuration.mode.rawValue).\(configuration.boardSize.rawValue)"
        }
    }
}
