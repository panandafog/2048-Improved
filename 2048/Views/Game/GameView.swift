//
//  GameView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct GameView: View {
    // MARK: - State
    
    @StateObject var game: GameModel
    @StateObject private var inputController = GameInputController()
    @Binding var showHowToPlay: Bool
    private let showsBottomControls: Bool
    
    // MARK: - Layout Metrics
    
    private static let verticalSpacing: CGFloat = 10
    private static let scoreStackHeight: CGFloat = 60
    private static let bottomStackHeight: CGFloat = 60
    
#if os(tvOS)
    private static let maxFieldSize: CGFloat = 760
    private static let minFieldSize: CGFloat = 420
    private static let defaultShowsBottomControls = false
#else
    private static let maxFieldSize: CGFloat = 500
    private static let minFieldSize: CGFloat = 300
    private static let defaultShowsBottomControls = true
#endif
    
    private var bottomControlsHeight: CGFloat {
        showsBottomControls ? Self.bottomStackHeight : 0
    }
    
    private var verticalSpacingCount: CGFloat {
        showsBottomControls ? 2 : 1
    }
    
    private var notFieldHeight: CGFloat {
        Self.scoreStackHeight + Self.verticalSpacing * verticalSpacingCount + bottomControlsHeight
    }
    
    // MARK: - Lifecycle
    
    init(
        showHowToPlay: Binding<Bool>,
        game: GameModel = GameModel(),
        showsBottomControls: Bool = Self.defaultShowsBottomControls
    ) {
        _showHowToPlay = showHowToPlay
        _game = StateObject(wrappedValue: game)
        self.showsBottomControls = showsBottomControls
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Self.verticalSpacing) {
                let fieldSize = min(
                    geometry.size.width,
                    max(0, geometry.size.height - notFieldHeight)
                )
                
                HStack {
                    TitleView()
                    Spacer()
                    ScoreView(kind: .current, value: game.score)
                    ScoreView(kind: .best, value: game.bestScore)
                }
                .frame(
                    width: fieldSize,
                    height: Self.scoreStackHeight
                )
                
                FieldView(game: game)
                    .frame(width: fieldSize, height: fieldSize)
                
                if showsBottomControls {
                    GameControlsView(
                        showHowToPlay: $showHowToPlay,
                        onNewGame: game.requestNewGame
                    )
                    .frame(
                        width: fieldSize,
                        height: Self.bottomStackHeight
                    )
                }
            }
            .position(
                x: geometry.frame(in: .local).midX,
                y: geometry.frame(in: .local).midY
            )
        }
        .alert(
            "Alert.NewGame.Title".localized,
            isPresented: $game.newGameRequested
        ) {
            Button("Start".localized, role: .destructive) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
            Button("Cancel".localized, role: .cancel) {
                game.cancelNewGame()
            }
        }
        .alert(
            "Alert.Victory.Title".localized,
            isPresented: $game.victory
        ) {
            Button("Alert.Victory.Button.NewGame".localized, role: .cancel) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
        }
        .alert(
            "Alert.Lose.Title".localized,
            isPresented: $game.lose
        ) {
            Button("Alert.Lose.Button.NewGame".localized, role: .cancel) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
        }
        .frame(
            minWidth: Self.minFieldSize,
            maxWidth: Self.maxFieldSize,
            minHeight: Self.minFieldSize + notFieldHeight,
            maxHeight: Self.maxFieldSize + notFieldHeight
        )
        .background(Color.gameForeground)
#if !os(tvOS)
        .gesture(moveDragGesture)
#endif
#if os(tvOS)
        .focusable()
        .onMoveCommand(perform: handleMoveCommand)
#endif
        .onAppear(perform: handleAppear)
        .onDisappear(perform: handleDisappear)
    }
}

private extension GameView {
    // MARK: - Lifecycle
    
    func handleAppear() {
        startGame()
        inputController.start(game: game)
    }
    
    func handleDisappear() {
        inputController.stop()
    }
    
    func startGame() {
        do {
            try game.start()
        } catch {
            fatalError("Can't start the game")
        }
    }
}

// MARK: - Preview

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showHowToPlay: .init(get: { true }, set: { _ in }))
    }
}
