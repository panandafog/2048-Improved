//
//  AnomalyStatusView.swift
//  2048
//

import SwiftUI

struct AnomalyStatusView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        VStack(spacing: AnomalyStatusLayout.spacing) {
            HStack {
                Label("GameMode.Anomaly".localized, systemImage: "sparkles")
                    .font(AnomalyStatusLayout.font)
                    .foregroundColor(.labelDark)

                Spacer()

                if let kind = game.nextAnomalyKind,
                   let moves = game.movesUntilNextAnomaly {
                    Label(
                        String(
                            format: "Anomaly.Next".localized,
                            kind.title,
                            moves
                        ),
                        systemImage: kind.systemImage
                    )
                    .font(AnomalyStatusLayout.font)
                    .foregroundColor(.labelDark)
                }
            }

            ProgressView(value: game.anomalyProgress)
                .tint(.accentColor)
        }
    }
}

private enum AnomalyStatusLayout {
#if os(tvOS)
    static let spacing: CGFloat = 8
    static let font = Font.headline
#else
    static let spacing: CGFloat = 4
    static let font = Font.caption.bold()
#endif
}
