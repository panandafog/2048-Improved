//
//  TVContentView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

#if os(tvOS)
import SwiftUI

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
    static let buttonWidth: CGFloat = 460
}

// MARK: - Button Style

private struct TVMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .foregroundColor(.labelLight)
            .frame(width: TVMenuLayout.buttonWidth)
            .padding()
            .background(Color.buttonBackground)
            .cornerRadius(.CornerRadius.button)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct TVContentView_Previews: PreviewProvider {
    static var previews: some View {
        TVContentView()
    }
}
#endif
