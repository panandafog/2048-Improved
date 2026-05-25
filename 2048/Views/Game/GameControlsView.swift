//
//  GameControlsView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct GameControlsView: View {
    // MARK: - Input
    
    @Binding var showHowToPlay: Bool
    let onNewGame: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Button("Button.HowToPlay".localized, action: toggleHowToPlay)
                .buttonStyle(HowToPlayButton())
            
            Button("Button.NewGame".localized, action: onNewGame)
                .buttonStyle(GameButton())
        }
    }
}

private extension GameControlsView {
    // MARK: - Actions
    
    func toggleHowToPlay() {
        withAnimation {
            showHowToPlay.toggle()
        }
    }
}

// MARK: - Preview

struct GameControlsView_Previews: PreviewProvider {
    static var previews: some View {
        GameControlsView(
            showHowToPlay: .init(get: { false }, set: { _ in }),
            onNewGame: {}
        )
    }
}
