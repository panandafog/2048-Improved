//
//  TVHowToPlayView.swift
//  2048
//
//  Created by Andrey on 24.05.2026.
//

import SwiftUI

#if os(tvOS)
struct TVHowToPlayView: View {
    @State private var selectedMode: GameMode
    @FocusState private var isModePickerFocused: Bool

    let onExitCommand: (() -> Void)?

    init(
        initialMode: GameMode = .classic,
        onExitCommand: (() -> Void)? = nil
    ) {
        _selectedMode = State(initialValue: initialMode)
        self.onExitCommand = onExitCommand
    }

    var body: some View {
        VStack(spacing: TVHowToPlayLayout.contentSpacing) {
            Text("Button.HowToPlay".localized)
                .font(.largeTitle.bold())
                .foregroundColor(.labelDark)

            modePicker

            ScrollView {
                VStack(spacing: TVHowToPlayLayout.sectionSpacing) {
                    Text("HowToPlay.tvOS".localized)
                        .font(.title2)
                        .foregroundColor(.labelDark)
                        .multilineTextAlignment(.center)
                        .lineSpacing(TVHowToPlayLayout.textLineSpacing)
                        .frame(maxWidth: TVHowToPlayLayout.textMaxWidth)

                    if selectedMode == .anomaly {
                        AnomalyGuideView()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, TVHowToPlayLayout.horizontalPadding)
        .padding(.vertical, TVHowToPlayLayout.verticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gameForeground)
        .onExitCommand(perform: onExitCommand)
        .onAppear {
            isModePickerFocused = true
        }
    }
}

private extension TVHowToPlayView {
    var modePicker: some View {
        Picker("ModeSelection.Title".localized, selection: $selectedMode) {
            ForEach(GameMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: TVHowToPlayLayout.pickerMaxWidth)
        .focused($isModePickerFocused)
    }
}

private enum TVHowToPlayLayout {
    static let contentSpacing: CGFloat = 28
    static let sectionSpacing: CGFloat = 28
    static let horizontalPadding: CGFloat = 96
    static let verticalPadding: CGFloat = 48
    static let textLineSpacing: CGFloat = 8
    static let textMaxWidth: CGFloat = 920
    static let pickerMaxWidth: CGFloat = 680
}

// MARK: - Preview

struct TVHowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        TVHowToPlayView(initialMode: .anomaly)
    }
}
#endif
