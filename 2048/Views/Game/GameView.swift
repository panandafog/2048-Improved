//
//  GameView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct GameView: View {
    // MARK: - State

#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    
    @StateObject var game: GameModel
    @StateObject private var inputController = GameInputController()
    @State private var showModeSelection = false
    @Binding var showHowToPlay: Bool
    private let showsBottomControls: Bool
    private let onShowChallenges: () -> Void
#if os(tvOS)
    private let onExitCommand: (() -> Void)?
#endif
    
    // MARK: - Layout Metrics
    
    private static let scoreStackHeight: CGFloat = 60
    private static let bottomStackHeight: CGFloat = 60
    private static let anomalyStatusHeight: CGFloat = 36
    
#if os(tvOS)
    private static let verticalSpacing: CGFloat = 50
    private static let anomalyStatusTopPadding: CGFloat = 30
    private static let maxFieldSize: CGFloat = 760
    private static let classicMinFieldSize: CGFloat = 420
    private static let anomalyMinFieldSize: CGFloat = 420
    private static let defaultShowsBottomControls = false
#elseif os(macOS)
    private static let verticalSpacing: CGFloat = 10
    private static let anomalyStatusTopPadding: CGFloat = 0
    private static let maxFieldSize: CGFloat = 500
    private static let classicMinFieldSize: CGFloat = 320
    private static let anomalyMinFieldSize: CGFloat = 400
    private static let defaultShowsBottomControls = true
#else
    private static let verticalSpacing: CGFloat = 10
    private static let anomalyStatusTopPadding: CGFloat = 0
    private static let maxFieldSize: CGFloat = 500
    private static let classicMinFieldSize: CGFloat = 300
    private static let anomalyMinFieldSize: CGFloat = 300
    private static let defaultShowsBottomControls = true
#endif

    private var minimumFieldSize: CGFloat {
        game.mode == .anomaly
            ? Self.anomalyMinFieldSize
            : Self.classicMinFieldSize
    }

    private var maximumFieldSize: CGFloat {
#if os(iOS)
        horizontalSizeClass == .regular ? 720 : Self.maxFieldSize
#else
        Self.maxFieldSize
#endif
    }
    
    private var bottomControlsHeight: CGFloat {
        showsBottomControls ? Self.bottomStackHeight : 0
    }
    
    private var verticalSpacingCount: CGFloat {
        let baseSpacingCount: CGFloat = showsBottomControls ? 2 : 1
        return game.mode == .anomaly ? baseSpacingCount + 1 : baseSpacingCount
    }
    
    private var notFieldHeight: CGFloat {
        let statusHeight = game.mode == .anomaly ? Self.anomalyStatusHeight : 0
        let statusTopPadding = game.mode == .anomaly
            ? Self.anomalyStatusTopPadding
            : 0
        return Self.scoreStackHeight
            + statusHeight
            + statusTopPadding
            + Self.verticalSpacing * verticalSpacingCount
            + bottomControlsHeight
    }
    
    // MARK: - Lifecycle
    
    init(
        showHowToPlay: Binding<Bool>,
        game: GameModel = GameModel(),
        showsBottomControls: Bool = Self.defaultShowsBottomControls,
        onShowChallenges: @escaping () -> Void = {},
        onExitCommand: (() -> Void)? = nil
    ) {
        _showHowToPlay = showHowToPlay
        _game = StateObject(wrappedValue: game)
        self.showsBottomControls = showsBottomControls
        self.onShowChallenges = onShowChallenges
#if os(tvOS)
        self.onExitCommand = onExitCommand
#endif
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
                    TitleView(title: game.mode.title)
                    Spacer()
                    ScoreView(kind: .current, value: game.score)
                    ScoreView(kind: .best, value: game.bestScore)
                }
                .frame(
                    width: fieldSize,
                    height: Self.scoreStackHeight
                )

                if game.mode == .anomaly {
                    AnomalyStatusView(game: game)
                        .frame(width: fieldSize, height: Self.anomalyStatusHeight)
                        .padding(.top, Self.anomalyStatusTopPadding)
                }
                
                FieldView(game: game)
                    .frame(width: fieldSize, height: fieldSize)
                
                if showsBottomControls {
                    GameControlsView(
                        showHowToPlay: $showHowToPlay,
                        onShowChallenges: onShowChallenges,
                        onNewGame: handleNewGameRequest
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
            "Alert.Victory.Title".localized,
            isPresented: $game.victory
        ) {
            Button("Alert.Victory.Button.NewGame".localized, role: .cancel) {
                startNewGame(configuration: game.configuration)
            }
        }
        .alert(
            "Alert.Lose.Title".localized,
            isPresented: $game.lose
        ) {
            Button("Alert.Lose.Button.NewGame".localized, role: .cancel) {
                startNewGame(configuration: game.configuration)
            }
        }
        .frame(
            minWidth: minimumFieldSize,
            maxWidth: maximumFieldSize,
            minHeight: minimumFieldSize + notFieldHeight,
            maxHeight: maximumFieldSize + notFieldHeight
        )
        .background(Color.gameForeground)
#if !os(tvOS)
        .sheet(isPresented: $showModeSelection) {
            ModeSelectionView(
                initialConfiguration: game.configuration,
                onSelect: startNewGame,
                onCancel: { showModeSelection = false }
            )
        }
#endif
#if os(macOS)
        .background {
            GameKeyboardInputView { direction in
                game.move(direction)
            }
        }
#endif
#if !os(tvOS)
        .gesture(moveDragGesture)
#endif
#if os(tvOS)
        .focusable()
        .onMoveCommand(perform: handleMoveCommand)
        .onExitCommand(perform: onExitCommand)
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
    
    func handleNewGameRequest() {
        showModeSelection = true
    }
    
    func startNewGame(configuration: GameConfiguration) {
        do {
            try game.startNewGame(configuration: configuration)
            showModeSelection = false
        } catch {
            print("Can't start the game")
        }
    }
}

// MARK: - Preview

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showHowToPlay: .init(get: { true }, set: { _ in }))
    }
}
