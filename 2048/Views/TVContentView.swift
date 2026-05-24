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
    @State private var isShowingGame = false
    
    // MARK: - Layout
    
    private static let menuSpacing: CGFloat = 36
    private static let titleBottomPadding: CGFloat = 24
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.gameForeground
                .ignoresSafeArea()
            
            if isShowingGame {
                gameScreen
            } else {
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
            
            Button("Button.HowToPlay".localized, action: {})
                .buttonStyle(TVMenuButtonStyle())
                .disabled(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var gameScreen: some View {
        GameView(
            showHowToPlay: .constant(false),
            game: game,
            showsBottomControls: false
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onExitCommand(perform: returnToMenu)
    }
}

private extension TVContentView {
    // MARK: - Actions
    
    func startGame() {
        do {
            try game.startNewGame()
            isShowingGame = true
        } catch {
            print("Can't start the game")
        }
    }
    
    func continueGame() {
        isShowingGame = true
    }
    
    func returnToMenu() {
        isShowingGame = false
    }
}

// MARK: - Layout

private enum TVMenuLayout {
    static let titleScale: CGFloat = 2
}

// MARK: - Preview

struct TVContentView_Previews: PreviewProvider {
    static var previews: some View {
        TVContentView()
    }
}
#else
struct TVContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(
            showHowToPlay: .constant(false),
            game: .preview(),
            showsBottomControls: false
        )
        .previewDisplayName("TV game layout")
    }
}
#endif
