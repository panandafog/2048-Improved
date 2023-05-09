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
    @Published var victory = false
    @Published var lose = false
    
    @Published var bestScore: Int = ScoreRepository.bestScore {
        didSet {
            ScoreRepository.bestScore = bestScore
        }
    }
    @Published var newGameRequested = false
    
    var gameEnded: Bool {
        victory || lose
    }
    
    private (set) var fieldSize: Int
    
    private let calculationsQueue = DispatchQueue(
        label: "game.concurrent.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    init(fieldSize: Int = 4, winValue: Int = 2048) {
        self.fieldSize = fieldSize
        field = .init(fieldSize: fieldSize, winValue: winValue)
    }
    
    func start() throws {
        try field.generateNewCell()
        try field.generateNewCell()
    }
    
    func move(_ direction: MoveDirection) {
        guard !gameEnded else {
            return
        }
        
        calculationsQueue.async { [self] in
            do {
                let moveScore = try field.move(direction)
                DispatchQueue.main.async { [self] in
                    score += moveScore
                    bestScore = max(score, bestScore)
                    if field.isFull { lose = true }
                }
            } catch GameError.win {
                DispatchQueue.main.async { [self] in
                    victory = true
                }
            } catch GameError.cantMove {
                print("cantMove")
            } catch GameError.noFreeSpace {
                DispatchQueue.main.async { [self] in
                    lose = true
                }
            } catch {}
        }
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
