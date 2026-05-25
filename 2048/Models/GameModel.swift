//
//  GameModel.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import Combine
import SwiftUI

class GameModel: ObservableObject {
    // MARK: - State
    
    var field: Field
    
    @Published var score: Int = 0
    @Published var victory = false
    @Published var lose = false
    @Published private(set) var hasStarted = false
    @Published private(set) var hasMadeMove = false
    
    // MARK: - Score Persistence
    
    @Published var bestScore: Int = ScoreRepository.bestScore {
        didSet {
            ScoreRepository.bestScore = bestScore
        }
    }
    @Published var newGameRequested = false
    
    // MARK: - Derived State
    
    var gameEnded: Bool {
        victory || lose
    }
    
    var hasSaveableGame: Bool {
        hasMadeMove && !gameEnded
    }
    
    // MARK: - Private Properties
    
    private(set) var fieldSize: Int
    
    private let calculationsQueue = DispatchQueue(
        label: "game.concurrent.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    // MARK: - Lifecycle
    
    init(fieldSize: Int = 4, winValue: Int = 2048) {
        self.fieldSize = fieldSize
        field = .init(fieldSize: fieldSize, winValue: winValue)
    }
    
    // MARK: - Game Flow
    
    func start() throws {
        guard !hasStarted else {
            return
        }
        
        try field.generateNewCell()
        try field.generateNewCell()
        hasStarted = true
    }
    
    func move(_ direction: MoveDirection) {
        guard !gameEnded else {
            return
        }
        
        calculationsQueue.async { [self] in
            do {
                let moveScore = try field.move(direction)
                DispatchQueue.main.async { [self] in
                    hasMadeMove = true
                    score += moveScore
                    bestScore = max(score, bestScore)
                    if !field.canMove { lose = true }
                }
            } catch GameError.win {
                DispatchQueue.main.async { [self] in
                    hasMadeMove = true
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
    
    // MARK: - New Game Flow
    
    func requestNewGame() {
        newGameRequested = true
    }
    
    func startNewGame() throws {
        score = 0
        victory = false
        lose = false
        newGameRequested = false
        field.reset()
        hasStarted = false
        hasMadeMove = false
        
        try start()
        objectWillChange.send()
    }
    
    func cancelNewGame() {
        newGameRequested = false
    }
}
