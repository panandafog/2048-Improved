//
//  GameModel.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import Combine
import SwiftUI

enum ScreenshotScene: String {
    case anomalyGameplay = "anomaly-gameplay"
    case classicGameplay = "classic-gameplay"
    case classicBigField = "classic-big-field"
    case challengeJourney = "challenge-journey"
    case masterEveryAnomaly = "master-every-anomaly"
}

enum ScreenshotDemoMode {
#if DEBUG
    static let isEnabledInCode = false
    static var scene: ScreenshotScene? {
        let prefix = "--screenshot-scene="
        guard let argument = ProcessInfo.processInfo.arguments.first(where: {
            $0.hasPrefix(prefix)
        }) else {
            return nil
        }

        return ScreenshotScene(rawValue: String(argument.dropFirst(prefix.count)))
    }

    static var isEnabled: Bool {
        isEnabledInCode
            || scene != nil
            || ProcessInfo.processInfo.arguments.contains("--screenshot-demo")
    }
#else
    static let scene: ScreenshotScene? = nil
    static let isEnabled = false
#endif

    static var activeScene: ScreenshotScene {
        scene ?? .anomalyGameplay
    }

    static var configuration: GameConfiguration {
        switch activeScene {
        case .anomalyGameplay, .masterEveryAnomaly:
            return GameConfiguration(mode: .anomaly, boardSize: .large)
        case .classicGameplay, .challengeJourney:
            return GameConfiguration(mode: .classic, boardSize: .standard)
        case .classicBigField:
            return GameConfiguration(mode: .classic, boardSize: .large)
        }
    }

    static var score: Int {
        switch activeScene {
        case .anomalyGameplay, .masterEveryAnomaly:
            return 4_896
        case .classicGameplay, .challengeJourney:
            return 3_680
        case .classicBigField:
            return 8_292
        }
    }

    static let bestScore = 12_672
    static var moveCount: Int {
        activeScene == .anomalyGameplay ? 17 : 96
    }
    static let nextAnomalyKind = AnomalyKind.bomb
}

class GameModel: ObservableObject {
    // MARK: - State
    
    @Published private(set) var field: Field
    @Published private(set) var mode: GameMode
    @Published private(set) var boardSize: BoardSize
    
    @Published var score: Int = 0
    @Published var victory = false
    @Published var lose = false
    @Published private(set) var hasStarted = false
    @Published private(set) var hasMadeMove = false
    @Published private(set) var progress: GameProgress
    
    // MARK: - Score Persistence
    
    @Published var bestScore: Int {
        didSet {
            ScoreRepository.setBestScore(bestScore, for: configuration)
        }
    }
    
    // MARK: - Derived State
    
    var gameEnded: Bool {
        victory || lose
    }
    
    var hasSaveableGame: Bool {
        hasMadeMove && !gameEnded
    }

    var configuration: GameConfiguration {
        GameConfiguration(mode: mode, boardSize: boardSize)
    }

    var nextAnomalyKind: AnomalyKind? {
        field.nextAnomalyKind
    }

    var movesUntilNextAnomaly: Int? {
        guard mode == .anomaly else {
            return nil
        }

        return Self.anomalyInterval - moveCount % Self.anomalyInterval
    }

    var anomalyProgress: Double {
        guard mode == .anomaly else {
            return 0
        }

        return Double(moveCount % Self.anomalyInterval) / Double(Self.anomalyInterval)
    }
    
    // MARK: - Private Properties
    
    private var moveCount = 0
    private static let anomalyInterval = 10
    
    // MARK: - Lifecycle
    
    init(
        boardSize: BoardSize = .standard,
        winValue: Int = 2048,
        mode: GameMode = .classic
    ) {
        let configuration = ScreenshotDemoMode.isEnabled
            ? ScreenshotDemoMode.configuration
            : GameConfiguration(mode: mode, boardSize: boardSize)

        self.mode = configuration.mode
        self.boardSize = configuration.boardSize
        field = Field(
            fieldSize: configuration.boardSize.rawValue,
            winValue: winValue,
            mode: configuration.mode
        )
        bestScore = ScreenshotDemoMode.isEnabled
            ? ScreenshotDemoMode.bestScore
            : ScoreRepository.bestScore(for: configuration)
        progress = .empty(configuration: configuration)

        if ScreenshotDemoMode.isEnabled {
            let cells = SampleBoard.cells(
                fieldSize: configuration.boardSize.rawValue,
                mode: configuration.mode
            )
            field.loadSample(
                cells,
                nextAnomalyKind: ScreenshotDemoMode.nextAnomalyKind
            )
            score = ScreenshotDemoMode.score
            moveCount = ScreenshotDemoMode.moveCount
            hasStarted = true
            hasMadeMove = true
            progress = GameProgress(
                configuration: configuration,
                score: score,
                moveCount: moveCount,
                highestTile: field.highestTile
            )
        }
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
        
        do {
            let result = try field.move(
                direction,
                generatesAnomaly: shouldGenerateAnomaly
            )
            hasMadeMove = true
            score += result.score
            bestScore = max(score, bestScore)
            moveCount += 1
            publishProgress(highestTile: result.highestTile)

            if result.didWin {
                victory = true
            } else if !field.canMove {
                lose = true
            }
        } catch GameError.cantMove {
            print("cantMove")
        } catch GameError.noFreeSpace {
            lose = true
        } catch {
            return
        }
    }
    
    // MARK: - New Game Flow
    
    func startNewGame(configuration newConfiguration: GameConfiguration? = nil) throws {
        let targetConfiguration = newConfiguration ?? configuration

        if targetConfiguration != configuration {
            mode = targetConfiguration.mode
            boardSize = targetConfiguration.boardSize
            field = Field(
                fieldSize: targetConfiguration.boardSize.rawValue,
                winValue: field.winValue,
                mode: targetConfiguration.mode
            )
            bestScore = ScoreRepository.bestScore(for: targetConfiguration)
        } else {
            field.reset()
        }

        score = 0
        victory = false
        lose = false
        hasStarted = false
        hasMadeMove = false
        moveCount = 0
        progress = .empty(configuration: targetConfiguration)
        
        try start()
        objectWillChange.send()
    }
    
    private func publishProgress(highestTile: Int) {
        progress = GameProgress(
            configuration: configuration,
            score: score,
            moveCount: moveCount,
            highestTile: highestTile
        )
    }

    private var shouldGenerateAnomaly: Bool {
        mode == .anomaly && (moveCount + 1).isMultiple(of: Self.anomalyInterval)
    }
}
