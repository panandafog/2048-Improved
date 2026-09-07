//
//  TVContentView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

#if os(tvOS)
struct TVContentView: View {
    // MARK: - State
    
    @StateObject private var game: GameModel
    @StateObject private var challenges: ChallengeStore
    @State private var screen = TVScreen.menu
    
    // MARK: - Layout
    
    private static let menuSpacing: CGFloat = 40
    private static let titleBottomPadding: CGFloat = 24

    // MARK: - Lifecycle

    init() {
        let game = GameModel()
        _game = StateObject(wrappedValue: game)
        _challenges = StateObject(wrappedValue: ChallengeStore(game: game))
        _screen = State(initialValue: Self.initialScreen)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.gameForeground
                .ignoresSafeArea()
            
            switch screen {
            case .game:
                gameScreen
            case .howToPlay:
                howToPlayScreen
            case .challenges:
                challengesScreen
            case .modeSelection:
                modeSelectionScreen
            case .menu:
                menu
            }
        }
        .achievementToast(store: challenges)
    }
}

private extension TVContentView {
    // MARK: - Views
    
    var menu: some View {
        VStack(spacing: Self.menuSpacing) {
            TitleView(title: "App.Name".localized)
                .scaleEffect(TVMenuLayout.titleScale)
                .padding(.bottom, Self.titleBottomPadding)
            
            if game.hasSaveableGame {
                Button("Button.ContinueGame".localized, action: continueGame)
                    .buttonStyle(TVMenuButtonStyle())
            }
            
            Button("Button.StartGame".localized, action: showModeSelection)
                .buttonStyle(TVMenuButtonStyle())

            Button("Button.Challenges".localized, action: showChallenges)
                .buttonStyle(TVMenuButtonStyle(role: .secondary))
            
            Button("Button.HowToPlay".localized, action: showHowToPlay)
                .buttonStyle(TVMenuButtonStyle(role: .secondary))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            menuScoreRow
                .padding()
        }
    }
    
    @ViewBuilder
    var menuScoreRow: some View {
        if showsMenuScoreRow {
            HStack {
                if showsCurrentScore {
                    ScoreView(kind: .current, value: game.score)
                        .padding(.trailing)
                }
                
                if showsBestScore {
                    ScoreView(
                        kind: .best,
                        value: game.bestScore,
                        title: showsCurrentScore ? nil : "BestScore".localized
                    )
                }
            }
        }
    }
    
    var gameScreen: some View {
        GameView(
            showHowToPlay: .constant(false),
            game: game,
            showsBottomControls: false,
            onExitCommand: returnToMenu
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var howToPlayScreen: some View {
        TVHowToPlayView(
            initialMode: game.mode,
            initialPage: ScreenshotDemoMode.scene == .masterEveryAnomaly ? 1 : 0,
            onExitCommand: returnToMenu
        )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var challengesScreen: some View {
        ChallengesView(store: challenges, onExitCommand: returnToMenu)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var modeSelectionScreen: some View {
        ModeSelectionView(
            initialConfiguration: game.configuration,
            onSelect: startNewGame,
            onCancel: returnToMenu
        )
    }
}

private extension TVContentView {
    static var initialScreen: TVScreen {
        switch ScreenshotDemoMode.scene {
        case .challengeJourney:
            return .challenges
        case .masterEveryAnomaly:
            return .howToPlay
        case .some:
            return .game
        case .none:
            return ScreenshotDemoMode.isEnabled ? .game : .menu
        }
    }
}

private extension TVContentView {
    // MARK: - Actions
    
    func showModeSelection() {
        screen = .modeSelection
    }

    func startNewGame(configuration: GameConfiguration) {
        do {
            try game.startNewGame(configuration: configuration)
            screen = .game
        } catch {
            print("Can't start the game")
        }
    }
    
    func continueGame() {
        screen = .game
    }
    
    func showHowToPlay() {
        screen = .howToPlay
    }

    func showChallenges() {
        screen = .challenges
    }
    
    func returnToMenu() {
        screen = .menu
    }
}

private extension TVContentView {
    // MARK: - Derived State
    
    var showsMenuScoreRow: Bool {
        showsCurrentScore || showsBestScore
    }
    
    var showsCurrentScore: Bool {
        game.hasSaveableGame
    }
    
    var showsBestScore: Bool {
        game.bestScore > 0
    }
}

// MARK: - Layout

private enum TVMenuLayout {
    static let titleScale: CGFloat = 2
}

private enum TVScreen {
    case menu
    case game
    case howToPlay
    case challenges
    case modeSelection
}

// MARK: - Preview

struct TVContentView_Previews: PreviewProvider {
    static var previews: some View {
        TVContentView()
    }
}
#endif
