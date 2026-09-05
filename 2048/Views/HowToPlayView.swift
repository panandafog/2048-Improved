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

    init(initialMode: GameMode = .classic) {
        self.initialMode = initialMode
        _selectedMode = State(initialValue: initialMode)
    }

    var body: some View {
        VStack(spacing: HowToPlayLayout.spacing) {
            Text("Button.HowToPlay".localized)
                .font(.title.bold())
                .foregroundColor(.labelDark)

            modePicker

            ScrollView {
                instructions
                    .frame(maxWidth: HowToPlayLayout.contentMaxWidth)
                    .frame(maxWidth: .infinity)
            }

            Button("Done".localized) {
                dismiss()
            }
            .buttonStyle(GameButton())
        }
        .padding(HowToPlayLayout.padding)
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

private extension HowToPlayView {
    var modePicker: some View {
        Picker("ModeSelection.Title".localized, selection: $selectedMode) {
            ForEach(GameMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: HowToPlayLayout.pickerMaxWidth)
    }

    @ViewBuilder
    var instructions: some View {
        VStack(spacing: HowToPlayLayout.sectionSpacing) {
            Text(baseInstructions)
                .font(.callout)
                .foregroundColor(.labelDark)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if selectedMode == .anomaly {
                AnomalyGuideView()
            }
        }
    }

    var baseInstructions: String {
#if os(macOS)
        return "HowToPlay.macOS".localized
#else
        return "HowToPlay.other".localized
#endif
    }
}

struct AnomalyGuideView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AnomalyGuideLayout.spacing) {
            Text("AnomalyGuide.Title".localized)
                .font(AnomalyGuideLayout.titleFont)
                .foregroundColor(.labelDark)

            ForEach(AnomalyKind.allCases) { kind in
                AnomalyGuideRow(kind: kind)
            }
        }
        .frame(maxWidth: AnomalyGuideLayout.maxWidth)
    }
}

private struct AnomalyGuideRow: View {
    let kind: AnomalyKind

    var body: some View {
        HStack(spacing: AnomalyGuideLayout.rowSpacing) {
            FieldCellView(value: sampleValue, kind: cellKind)
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
    static let spacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let padding: CGFloat = 24
    static let contentMaxWidth: CGFloat = 560
    static let pickerMaxWidth: CGFloat = 360

#if os(macOS)
    static let minimumWidth: CGFloat = 480
    static let minimumHeight: CGFloat = 560
#else
    static let minimumWidth: CGFloat = 0
    static let minimumHeight: CGFloat = 0
#endif
}

private enum AnomalyGuideLayout {
#if os(tvOS)
    static let spacing: CGFloat = 20
    static let rowSpacing: CGFloat = 24
    static let textSpacing: CGFloat = 8
    static let tileSize: CGFloat = 96
    static let maxWidth: CGFloat = 920
    static let titleFont = Font.title.bold()
    static let rowTitleFont = Font.title2.bold()
    static let descriptionFont = Font.title3
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
