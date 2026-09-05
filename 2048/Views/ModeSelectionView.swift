//
//  ModeSelectionView.swift
//  2048
//

import SwiftUI

struct ModeSelectionView: View {
    @AppStorage(ModeSelectionStorage.hasSeenAnomalyGuideKey)
    private var hasSeenAnomalyGuide = false
    @State private var page = ModeSelectionPage.configuration
    @State private var selectedMode: GameMode
    @State private var selectedBoardSize: BoardSize

    let onSelect: (GameConfiguration) -> Void
    let onCancel: () -> Void

    init(
        initialConfiguration: GameConfiguration = .standard,
        onSelect: @escaping (GameConfiguration) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _selectedMode = State(initialValue: initialConfiguration.mode)
        _selectedBoardSize = State(initialValue: initialConfiguration.boardSize)
        self.onSelect = onSelect
        self.onCancel = onCancel
    }

    var body: some View {
        Group {
            switch page {
            case .configuration:
                configurationView
            case .anomalyGuide:
                anomalyGuide
            }
        }
        .padding(ModeSelectionLayout.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gameForeground)
#if os(tvOS)
        .onExitCommand(perform: handleExit)
#endif
    }
}

private extension ModeSelectionView {
    var configurationView: some View {
        VStack(spacing: ModeSelectionLayout.spacing) {
            Text("NewGame.Title".localized)
                .font(ModeSelectionLayout.titleFont)
                .foregroundColor(.labelDark)

            selectionSection(title: "GameMode.Title".localized) {
                Picker("GameMode.Title".localized, selection: $selectedMode) {
                    ForEach(GameMode.allCases) { mode in
                        Label(mode.title, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
            }

            selectionSection(title: "BoardSize.Title".localized) {
                Picker("BoardSize.Title".localized, selection: $selectedBoardSize) {
                    ForEach(BoardSize.allCases) { boardSize in
                        Text(boardSize.title)
                            .tag(boardSize)
                    }
                }
            }

            startButton

#if !os(tvOS)
            Button("Cancel".localized, action: onCancel)
                .buttonStyle(HowToPlayButton())
#endif
        }
    }

    func selectionSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: ModeSelectionLayout.sectionSpacing) {
            Text(title)
                .font(ModeSelectionLayout.sectionTitleFont)
                .foregroundColor(.labelDark)

            content()
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: ModeSelectionLayout.pickerMaxWidth)
        }
    }

    @ViewBuilder
    var startButton: some View {
#if os(tvOS)
        Button("Start".localized, action: startSelectedGame)
            .buttonStyle(TVMenuButtonStyle())
#else
        Button("Start".localized, action: startSelectedGame)
            .buttonStyle(GameButton())
#endif
    }

    var anomalyGuide: some View {
        VStack(spacing: ModeSelectionLayout.spacing) {
            ScrollView {
                AnomalyGuideView()
                    .frame(maxWidth: .infinity)
            }

#if os(tvOS)
            Button("AnomalyGuide.Play".localized, action: startAnomalyGame)
                .buttonStyle(TVMenuButtonStyle())
#else
            Button("AnomalyGuide.Play".localized, action: startAnomalyGame)
                .buttonStyle(GameButton())

            Button("Back".localized) {
                page = .configuration
            }
            .buttonStyle(HowToPlayButton())
#endif
        }
    }

    var configuration: GameConfiguration {
        GameConfiguration(
            mode: selectedMode,
            boardSize: selectedBoardSize
        )
    }

    func startSelectedGame() {
        guard selectedMode == .anomaly, !hasSeenAnomalyGuide else {
            onSelect(configuration)
            return
        }

        page = .anomalyGuide
    }

    func startAnomalyGame() {
        hasSeenAnomalyGuide = true
        onSelect(configuration)
    }

#if os(tvOS)
    func handleExit() {
        if page == .anomalyGuide {
            page = .configuration
        } else {
            onCancel()
        }
    }
#endif
}

private enum ModeSelectionLayout {
#if os(tvOS)
    static let spacing: CGFloat = 32
    static let sectionSpacing: CGFloat = 12
    static let padding: CGFloat = 64
    static let pickerMaxWidth: CGFloat = 720
    static let titleFont = Font.largeTitle.bold()
    static let sectionTitleFont = Font.title3.bold()
#else
    static let spacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 8
    static let padding: CGFloat = 24
    static let pickerMaxWidth: CGFloat = 360
    static let titleFont = Font.title.bold()
    static let sectionTitleFont = Font.headline
#endif
}

private enum ModeSelectionPage {
    case configuration
    case anomalyGuide
}

private enum ModeSelectionStorage {
    static let hasSeenAnomalyGuideKey = "HasSeenAnomalyGuideV2"
}

struct ModeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectionView(onSelect: { _ in }, onCancel: {})
    }
}
