//
//  TVHowToPlayView.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

#if os(tvOS)
struct TVHowToPlayView: View {
    // MARK: - State
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Input
    
    let onExitCommand: (() -> Void)?
    
    // MARK: - Lifecycle
    
    init(onExitCommand: (() -> Void)? = nil) {
        self.onExitCommand = onExitCommand
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: TVHowToPlayLayout.contentSpacing) {
            Text("Button.HowToPlay".localized)
                .font(.largeTitle.bold())
                .foregroundColor(.labelDark)
            
            Text("HowToPlay.tvOS".localized)
                .font(.title2)
                .foregroundColor(.labelDark)
                .multilineTextAlignment(.center)
                .lineSpacing(TVHowToPlayLayout.textLineSpacing)
                .frame(maxWidth: TVHowToPlayLayout.textMaxWidth)
        }
        .padding(.horizontal, TVHowToPlayLayout.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gameForeground)
        .focusable()
        .focused($isFocused)
        .onExitCommand(perform: onExitCommand)
        .onAppear(perform: focus)
    }
}

private extension TVHowToPlayView {
    func focus() {
        isFocused = true
    }
}

private enum TVHowToPlayLayout {
    static let contentSpacing: CGFloat = 36
    static let horizontalPadding: CGFloat = 96
    static let textLineSpacing: CGFloat = 8
    static let textMaxWidth: CGFloat = 920
}

// MARK: - Preview

struct TVHowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        TVHowToPlayView()
    }
}
#endif
