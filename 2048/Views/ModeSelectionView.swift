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
#if os(tvOS)
    @FocusState private var focusedAction: ModeSelectionAction?
#endif

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
    @ViewBuilder
    var configurationView: some View {
#if os(tvOS)
        if #available(tvOS 16.0, *) {
            tvConfigurationView
                .defaultFocus($focusedAction, .start)
        } else {
            tvConfigurationView
        }
#else
        compactConfigurationView
#endif
    }

    var compactConfigurationView: some View {
        VStack(spacing: ModeSelectionLayout.spacing) {
            Text("NewGame.Title".localized)
                .font(ModeSelectionLayout.titleFont)
                .foregroundColor(.labelDark)

            boardPreview

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

            actionButtons
        }
    }

#if os(tvOS)
    var tvConfigurationView: some View {
        HStack(spacing: ModeSelectionLayout.panelSpacing) {
            VStack(alignment: .leading, spacing: ModeSelectionLayout.spacing) {
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

                actionButtons
                    .padding(.top, ModeSelectionLayout.actionTopPadding)
            }
            .frame(maxWidth: ModeSelectionLayout.controlsMaxWidth)

            Divider()
                .overlay(Color.labelDark.opacity(ModeSelectionLayout.dividerOpacity))
                .padding(.vertical, ModeSelectionLayout.dividerVerticalPadding)

            boardPreview
        }
    }
#endif

    var boardPreview: some View {
        HowToPlayBoardPreview(
            mode: selectedMode,
            fieldSize: selectedBoardSize.rawValue
        )
        .frame(
            width: ModeSelectionLayout.boardPreviewSize,
            height: ModeSelectionLayout.boardPreviewSize
        )
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

    var actionButtons: some View {
        HStack(spacing: ModeSelectionLayout.buttonSpacing) {
            Button(action: onCancel) {
                Text("Cancel".localized)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(HowToPlayButton())

            startButton
        }
        .frame(maxWidth: ModeSelectionLayout.pickerMaxWidth)
    }

    var startButton: some View {
        Button(action: startSelectedGame) {
            Text("Start".localized)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(GameButton())
#if os(macOS)
        .keyboardShortcut(.defaultAction)
#elseif os(tvOS)
        .focused($focusedAction, equals: .start)
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
    static let spacing: CGFloat = 24
    static let sectionSpacing: CGFloat = 12
    static let padding: CGFloat = 48
    static let pickerMaxWidth: CGFloat = 660
    static let controlsMaxWidth: CGFloat = 660
    static let boardPreviewSize: CGFloat = 620
    static let panelSpacing: CGFloat = 72
    static let actionTopPadding: CGFloat = 48
    static let dividerVerticalPadding: CGFloat = 72
    static let dividerOpacity: Double = 0.3
    static let buttonSpacing: CGFloat = 20
    static let titleFont = Font.largeTitle.bold()
    static let sectionTitleFont = Font.title3.bold()
#elseif os(macOS)
    static let spacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 8
    static let padding: CGFloat = 24
    static let pickerMaxWidth: CGFloat = 360
    static let boardPreviewSize: CGFloat = 300
    static let buttonSpacing: CGFloat = 12
    static let titleFont = Font.title.bold()
    static let sectionTitleFont = Font.headline
#else
    static let spacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 8
    static let padding: CGFloat = 24
    static let pickerMaxWidth: CGFloat = 360
    static let boardPreviewSize: CGFloat = 280
    static let buttonSpacing: CGFloat = 12
    static let titleFont = Font.title.bold()
    static let sectionTitleFont = Font.headline
#endif
}

private enum ModeSelectionPage {
    case configuration
    case anomalyGuide
}

#if os(tvOS)
private enum ModeSelectionAction: Hashable {
    case start
}
#endif

private enum ModeSelectionStorage {
    static let hasSeenAnomalyGuideKey = "HasSeenAnomalyGuideV2"
}

struct ModeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectionView(onSelect: { _ in }, onCancel: {})
    }
}
