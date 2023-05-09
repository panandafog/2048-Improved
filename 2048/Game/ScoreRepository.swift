//
//  ScoreRepository.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import Foundation

enum ScoreRepository {
    
    private static let defaults = UserDefaults.standard
    private static let bestScoreKey = "BestScore"
    
    static var bestScore: Int {
        get {
            Self.defaults.integer(forKey: Self.bestScoreKey)
        }
        set {
            Self.defaults.setValue(newValue, forKey: Self.bestScoreKey)
        }
    }
}
