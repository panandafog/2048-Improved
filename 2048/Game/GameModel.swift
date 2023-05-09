//
//  GameModel.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import Combine
import SwiftUI

class GameModel: ObservableObject {
    
    var field: Field
    
    @Published var score: Int = 0
    @Published var bestScore: Int = ScoreRepository.bestScore {
        didSet {
            ScoreRepository.bestScore = bestScore
        }
    }
    @Published var newGameRequested = false
    
    private (set) var fieldSize: Int
    
    init(fieldSize: Int = 4) {
        self.fieldSize = fieldSize
        field = .init(fieldSize: fieldSize)
    }
    
    func start() throws {
        try field.generateNewCell()
        try field.generateNewCell()
    }
    
    func move(_ direction: MoveDirection) {
        do {
            try score += field.move(direction)
            bestScore = max(score, bestScore)
        } catch GameError.cantMove {
            print("cantMove")
        } catch GameError.noFreeSpace {
            print("noFreeSpace")
        } catch {}
    }
    
    func requestNewGame() {
        newGameRequested = true
    }
    
    func startNewGame() throws {
        score = 0
        field.reset()
        
        try start()
        objectWillChange.send()
    }
    
    func cancelNewGame() {
        newGameRequested = false
    }
}
