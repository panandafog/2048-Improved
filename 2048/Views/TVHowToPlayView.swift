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
    @State private var page = 0
    @FocusState private var isModePickerFocused: Bool

    private let initialMode: GameMode
    private let initialPage: Int
    let onExitCommand: (() -> Void)?

    init(
        initialMode: GameMode = .classic,
        initialPage: Int = 0,
        onExitCommand: (() -> Void)? = nil
    ) {
        self.initialMode = initialMode
        self.initialPage = initialPage
        _selectedMode = State(initialValue: initialMode)
        _page = State(initialValue: initialPage)
        self.onExitCommand = onExitCommand
    }

    var body: some View {
        VStack(spacing: TVHowToPlayLayout.contentSpacing) {
            Text("Button.HowToPlay".localized)
                .font(.largeTitle.bold())
                .foregroundColor(.labelDark)

            modePicker

            pageContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if pageCount > 1 {
                pageControls
            }
        }
        .padding(.horizontal, TVHowToPlayLayout.horizontalPadding)
        .padding(.vertical, TVHowToPlayLayout.verticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gameForeground)
        .onChange(of: selectedMode) { _ in
            page = 0
        }
        .onExitCommand(perform: onExitCommand)
        .onAppear {
            selectedMode = initialMode
            page = min(max(initialPage, 0), pageCount - 1)
            isModePickerFocused = initialPage == 0
        }
    }
}

private extension TVHowToPlayView {
    var modePicker: some View {
        Picker("GameMode.Title".localized, selection: $selectedMode) {
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

    @ViewBuilder
    var pageContent: some View {
        if page == 0 {
            overviewPage
        } else {
            AnomalyGuideView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var overviewPage: some View {
        HStack(spacing: TVHowToPlayLayout.overviewSpacing) {
            HowToPlayBoardPreview(mode: selectedMode)
                .frame(
                    width: TVHowToPlayLayout.boardSize,
                    height: TVHowToPlayLayout.boardSize
                )

            Divider()
                .overlay(Color.labelDark.opacity(TVHowToPlayLayout.dividerOpacity))
                .frame(height: TVHowToPlayLayout.dividerHeight)

            VStack(alignment: .leading, spacing: TVHowToPlayLayout.textSpacing) {
                Label(selectedMode.title, systemImage: selectedMode.systemImage)
                    .font(.title.bold())
                    .foregroundColor(.labelDark)

                Text(overviewInstructions)
                    .font(.title2)
                    .foregroundColor(.labelDark)
                    .lineSpacing(TVHowToPlayLayout.textLineSpacing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: TVHowToPlayLayout.textMaxWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var pageControls: some View {
        HStack(spacing: TVHowToPlayLayout.pageControlSpacing) {
            Button {
                changePage(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .accessibilityLabel("Previous".localized)
            }
            .buttonStyle(HowToPlayButton())
            .disabled(page == 0)

            Text(
                String(
                    format: "HowToPlay.Page".localized,
                    page + 1,
                    pageCount
                )
            )
            .font(.title3.bold())
            .foregroundColor(.labelDark)
            .frame(minWidth: TVHowToPlayLayout.pageLabelWidth)

            Button {
                changePage(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .accessibilityLabel("Next".localized)
            }
            .buttonStyle(HowToPlayButton())
            .disabled(page == pageCount - 1)
        }
    }

    var pageCount: Int {
        selectedMode == .anomaly ? 2 : 1
    }

    var overviewInstructions: String {
        if selectedMode == .anomaly {
            return "HowToPlay.Overview.Anomaly".localized
        }

        return "HowToPlay.Overview.tvOS".localized
    }

    func changePage(by offset: Int) {
        page = min(max(page + offset, 0), pageCount - 1)
    }
}

private enum TVHowToPlayLayout {
    static let contentSpacing: CGFloat = 24
    static let horizontalPadding: CGFloat = 96
    static let verticalPadding: CGFloat = 40
    static let pickerMaxWidth: CGFloat = 680
    static let overviewSpacing: CGFloat = 80
    static let boardSize: CGFloat = 430
    static let textSpacing: CGFloat = 24
    static let textLineSpacing: CGFloat = 8
    static let textMaxWidth: CGFloat = 680
    static let dividerHeight: CGFloat = 520
    static let dividerOpacity: Double = 0.3
    static let pageControlSpacing: CGFloat = 32
    static let pageLabelWidth: CGFloat = 120
}

// MARK: - Preview

struct TVHowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        TVHowToPlayView(initialMode: .anomaly)
    }
}
#endif
