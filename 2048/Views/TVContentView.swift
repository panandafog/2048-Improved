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
    
    @StateObject private var game = GameModel()
    @State private var screen = TVScreen.menu
    
    // MARK: - Layout
    
    private static let menuSpacing: CGFloat = 40
    private static let titleBottomPadding: CGFloat = 24
    
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
            case .menu:
                menu
            }
        }
    }
}

private extension TVContentView {
    // MARK: - Views
    
    var menu: some View {
        VStack(spacing: Self.menuSpacing) {
            TitleView()
                .scaleEffect(TVMenuLayout.titleScale)
                .padding(.bottom, Self.titleBottomPadding)
            
            if game.hasStarted {
                Button("Button.ContinueGame".localized, action: continueGame)
                    .buttonStyle(TVMenuButtonStyle())
            }
            
            Button("Button.StartGame".localized, action: startGame)
                .buttonStyle(TVMenuButtonStyle())
            
            Button("Button.HowToPlay".localized, action: showHowToPlay)
                .buttonStyle(TVMenuButtonStyle(role: .secondary))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        TVHowToPlayView(onExitCommand: returnToMenu)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension TVContentView {
    // MARK: - Actions
    
    func startGame() {
        do {
            try game.startNewGame()
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
    
    func returnToMenu() {
        screen = .menu
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
}

// MARK: - Preview

struct TVContentView_Previews: PreviewProvider {
    static var previews: some View {
        TVContentView()
    }
}
#endif
