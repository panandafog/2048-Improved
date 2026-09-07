//
//  HowToPlayView.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: GameMode
    private let initialMode: GameMode
    private let startsAtAnomalyGuide: Bool

    init(
        initialMode: GameMode = .classic,
        startsAtAnomalyGuide: Bool = false
    ) {
        self.initialMode = initialMode
        self.startsAtAnomalyGuide = startsAtAnomalyGuide
        _selectedMode = State(initialValue: initialMode)
    }

    var body: some View {
        VStack(spacing: HowToPlayLayout.sectionSpacing) {
            header
                .frame(maxWidth: HowToPlayLayout.contentMaxWidth)
                .padding(.horizontal, HowToPlayLayout.horizontalContentPadding)

            modePicker
                .frame(maxWidth: HowToPlayLayout.contentMaxWidth)
                .padding(.horizontal, HowToPlayLayout.horizontalContentPadding)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: HowToPlayLayout.contentSpacing) {
                        HowToPlayOverviewView(
                            mode: selectedMode,
                            instructions: instructions
                        )

                        if selectedMode == .anomaly {
                            AnomalyGuideView()
                                .id(HowToPlayScrollTarget.anomalyGuide)
                        }
                    }
                    .frame(maxWidth: HowToPlayLayout.contentMaxWidth)
                    .padding(.horizontal, HowToPlayLayout.horizontalContentPadding)
                    .padding(
                        .bottom,
                        startsAtAnomalyGuide
                            ? HowToPlayLayout.screenshotScrollBottomPadding
                            : HowToPlayLayout.scrollContentBottomPadding
                    )
                    .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea(edges: [.horizontal, .bottom])
                .onAppear {
                    guard startsAtAnomalyGuide else {
                        return
                    }

                    DispatchQueue.main.async {
                        proxy.scrollTo(
                            HowToPlayScrollTarget.anomalyGuide,
                            anchor: .top
                        )
                    }
                }
            }
        }
        .padding(.top, HowToPlayLayout.verticalContentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(
            minWidth: HowToPlayLayout.minimumWidth,
            minHeight: HowToPlayLayout.minimumHeight
        )
        .background(Color.gameForeground)
        .onAppear {
            selectedMode = initialMode
        }
    }
}

private enum HowToPlayScrollTarget {
    static let anomalyGuide = "anomaly-guide"
}

private extension HowToPlayView {
    var header: some View {
        HStack {
            Text("Button.HowToPlay".localized)
                .font(HowToPlayLayout.titleFont)
                .foregroundColor(.labelDark)

            Spacer()

            Button("Done".localized) {
                dismiss()
            }
            .buttonStyle(GameButton())
        }
    }

    var modePicker: some View {
        Picker("GameMode.Title".localized, selection: $selectedMode) {
            ForEach(GameMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: HowToPlayLayout.pickerMaxWidth)
        .frame(maxWidth: .infinity)
    }

    var instructions: String {
        if selectedMode == .anomaly {
            return "HowToPlay.Overview.Anomaly".localized
        }

#if os(macOS)
        return "HowToPlay.Overview.macOS".localized
#else
        return "HowToPlay.Overview.iOS".localized
#endif
    }
}

struct HowToPlayOverviewView: View {
    let mode: GameMode
    let instructions: String

    var body: some View {
        VStack(spacing: HowToPlayOverviewLayout.spacing) {
            Label(mode.title, systemImage: mode.systemImage)
                .font(HowToPlayOverviewLayout.titleFont)
                .foregroundColor(.labelDark)

            HowToPlayBoardPreview(mode: mode)
                .frame(
                    width: HowToPlayOverviewLayout.boardSize,
                    height: HowToPlayOverviewLayout.boardSize
                )

            Text(instructions)
                .font(HowToPlayOverviewLayout.descriptionFont)
                .foregroundColor(.labelDark)
                .multilineTextAlignment(.center)
                .lineSpacing(HowToPlayOverviewLayout.lineSpacing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct HowToPlayBoardPreview: View {
    let mode: GameMode
    let fieldSize: Int

    init(mode: GameMode, fieldSize: Int = 4) {
        self.mode = mode
        self.fieldSize = fieldSize
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = FieldLayoutMetrics(
                containerSize: geometry.size,
                fieldSize: fieldSize
            )

            ZStack {
                ForEach(metrics.indices, id: \.self) { row in
                    ForEach(metrics.indices, id: \.self) { column in
                        FieldCellView(value: nil, animationsEnabled: false)
                            .frame(
                                width: metrics.cellSize.width,
                                height: metrics.cellSize.height
                            )
                            .position(
                                metrics.center(
                                    for: Coordinate(row: row, col: column)
                                )
                            )
                    }
                }

                ForEach(SampleBoard.cells(fieldSize: fieldSize, mode: mode)) { cell in
                    FieldCellView(
                        value: cell.value,
                        kind: cell.kind,
                        animationsEnabled: false
                    )
                    .frame(
                        width: metrics.cellSize.width,
                        height: metrics.cellSize.height
                    )
                    .position(metrics.center(for: cell.coordinate))
                }
            }
            .background(Color.fieldForeground)
            .cornerRadius(FieldLayout.cornerRadius)
        }
        .accessibilityHidden(true)
    }
}

struct AnomalyGuideView: View {
    let kinds: [AnomalyKind]

    init(kinds: [AnomalyKind] = AnomalyKind.allCases) {
        self.kinds = kinds
    }

    @ViewBuilder
    var body: some View {
#if os(tvOS)
        VStack(alignment: .leading, spacing: AnomalyGuideLayout.spacing) {
            guideTitle

            HStack(alignment: .top, spacing: AnomalyGuideLayout.columnSpacing) {
                guideColumn(kinds: leftColumnKinds)

                Divider()
                    .overlay(Color.labelDark.opacity(AnomalyGuideLayout.dividerOpacity))
                    .frame(height: AnomalyGuideLayout.dividerHeight)

                guideColumn(kinds: rightColumnKinds)
            }
        }
        .frame(maxWidth: AnomalyGuideLayout.maxWidth)
#else
        VStack(alignment: .leading, spacing: AnomalyGuideLayout.spacing) {
            guideTitle

            guideRows
        }
        .frame(maxWidth: AnomalyGuideLayout.maxWidth)
#endif
    }

    var guideTitle: some View {
        Text("AnomalyGuide.Title".localized)
            .font(AnomalyGuideLayout.titleFont)
            .foregroundColor(.labelDark)
    }

    var guideRows: some View {
        ForEach(kinds) { kind in
            AnomalyGuideRow(kind: kind)
        }
    }

#if os(tvOS)
    func guideColumn(kinds: [AnomalyKind]) -> some View {
        VStack(alignment: .leading, spacing: AnomalyGuideLayout.spacing) {
            ForEach(kinds) { kind in
                AnomalyGuideRow(kind: kind)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var leftColumnKinds: [AnomalyKind] {
        kinds.enumerated().compactMap { index, kind in
            index.isMultiple(of: 2) ? kind : nil
        }
    }

    var rightColumnKinds: [AnomalyKind] {
        kinds.enumerated().compactMap { index, kind in
            index.isMultiple(of: 2) ? nil : kind
        }
    }
#endif
}

private struct AnomalyGuideRow: View {
    let kind: AnomalyKind

    var body: some View {
        HStack(spacing: AnomalyGuideLayout.rowSpacing) {
            ZStack {
                FieldCellView(
                    value: sampleValue,
                    kind: cellKind,
                    animationsEnabled: false
                )
            }
            .frame(
                width: AnomalyGuideLayout.tileSize,
                height: AnomalyGuideLayout.tileSize
            )

            VStack(alignment: .leading, spacing: AnomalyGuideLayout.textSpacing) {
                Label(kind.title, systemImage: kind.systemImage)
                    .font(AnomalyGuideLayout.rowTitleFont)
                    .foregroundColor(.labelDark)

                Text(kind.description)
                    .font(AnomalyGuideLayout.descriptionFont)
                    .foregroundColor(.labelDark)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    var sampleValue: Int {
        switch kind {
        case .wild:
            return 0
        case .frozen:
            return 8
        case .bomb:
            return 4
        case .power:
            return 8
        case .stone:
            return 8
        }
    }

    var cellKind: FieldCellKind {
        switch kind {
        case .wild:
            return .wild
        case .frozen:
            return .frozen(remainingMoves: 6)
        case .bomb:
            return .bomb
        case .power:
            return .power
        case .stone:
            return .stone(remainingMoves: 6)
        }
    }
}

private enum HowToPlayLayout {
    static let contentMaxWidth: CGFloat = 640
    static let pickerMaxWidth: CGFloat = 360
    static let horizontalContentPadding: CGFloat = 20
    static let verticalContentPadding: CGFloat = 20
    static let scrollContentBottomPadding: CGFloat = 24
    static let screenshotScrollBottomPadding: CGFloat = 320
    static let sectionSpacing: CGFloat = 20
    static let contentSpacing: CGFloat = 28
    static let minimumWidth: CGFloat = 320
    static let minimumHeight: CGFloat = 500
    static let titleFont = Font.title.bold()
}

private enum HowToPlayOverviewLayout {
#if os(tvOS)
    static let spacing: CGFloat = 24
    static let boardSize: CGFloat = 420
    static let lineSpacing: CGFloat = 8
    static let titleFont = Font.title.bold()
    static let descriptionFont = Font.title2
#else
    static let spacing: CGFloat = 18
    static let boardSize: CGFloat = 280
    static let lineSpacing: CGFloat = 3
    static let titleFont = Font.title2.bold()
    static let descriptionFont = Font.callout
#endif
}

private enum AnomalyGuideLayout {
#if os(tvOS)
    static let spacing: CGFloat = 18
    static let rowSpacing: CGFloat = 18
    static let textSpacing: CGFloat = 4
    static let tileSize: CGFloat = 78
    static let maxWidth: CGFloat = 1460
    static let columnSpacing: CGFloat = 52
    static let dividerHeight: CGFloat = 410
    static let dividerOpacity: Double = 0.3
    static let titleFont = Font.title2.bold()
    static let rowTitleFont = Font.title3.bold()
    static let descriptionFont = Font.body
#else
    static let spacing: CGFloat = 16
    static let rowSpacing: CGFloat = 16
    static let textSpacing: CGFloat = 4
    static let tileSize: CGFloat = 68
    static let maxWidth: CGFloat = 560
    static let titleFont = Font.title2.bold()
    static let rowTitleFont = Font.headline
    static let descriptionFont = Font.callout
#endif
}

// MARK: - Preview

struct HowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayView(initialMode: .anomaly)
    }
}
