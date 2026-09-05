//
//  ContentView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State

    @StateObject private var game: GameModel
    @StateObject private var challenges: ChallengeStore
    @State private var showHowToPlay = false
    @State private var showChallenges = false

    // MARK: - Lifecycle

    init() {
        let game = GameModel()
        _game = StateObject(wrappedValue: game)
        _challenges = StateObject(wrappedValue: ChallengeStore(game: game))
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                GameView(
                    showHowToPlay: $showHowToPlay,
                    game: game,
                    onShowChallenges: { showChallenges = true }
                )
                Spacer()
            }
            Spacer()
        }
        .background(Color.gameForeground)
        .sheet(isPresented: $showHowToPlay) {
            HowToPlayView(initialMode: game.mode)
        }
        .sheet(isPresented: $showChallenges) {
            ChallengesView(store: challenges)
        }
        .achievementToast(store: challenges)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
