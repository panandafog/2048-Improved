//
//  ChallengesView.swift
//  2048
//

import SwiftUI

struct ChallengesView: View {
    @ObservedObject var store: ChallengeStore
    @Environment(\.dismiss) private var dismiss

#if os(tvOS)
    let onExitCommand: (() -> Void)?
#endif

    init(store: ChallengeStore, onExitCommand: (() -> Void)? = nil) {
        self.store = store
#if os(tvOS)
        self.onExitCommand = onExitCommand
#endif
    }

    var body: some View {
        VStack(spacing: ChallengesLayout.sectionSpacing) {
            header
#if os(tvOS)
                .frame(maxWidth: ChallengesLayout.contentMaxWidth)
                .padding(.horizontal, ChallengesLayout.headerHorizontalPadding)
#elseif os(iOS) || os(macOS)
                .frame(maxWidth: ChallengesLayout.contentMaxWidth)
                .padding(.horizontal, ChallengesLayout.horizontalContentPadding)
#endif

            ScrollView {
                LazyVGrid(columns: ChallengesLayout.columns, spacing: ChallengesLayout.itemSpacing) {
                    ForEach(store.challenges) { challenge in
                        ChallengeRow(
                            challenge: challenge,
                            isCompleted: store.isCompleted(challenge)
                        )
                    }
                }
#if os(tvOS)
                .frame(maxWidth: ChallengesLayout.contentMaxWidth)
                .padding(.horizontal, ChallengesLayout.scrollContentHorizontalPadding)
                .padding(.vertical, ChallengesLayout.scrollContentVerticalPadding)
                .frame(maxWidth: .infinity)
#elseif os(iOS) || os(macOS)
                .frame(maxWidth: ChallengesLayout.contentMaxWidth)
                .padding(.horizontal, ChallengesLayout.horizontalContentPadding)
                .padding(.bottom, ChallengesLayout.scrollContentBottomPadding)
                .frame(maxWidth: .infinity)
#endif
            }
#if os(tvOS)
            .ignoresSafeArea(edges: [.horizontal, .bottom])
#elseif os(iOS) || os(macOS)
            .ignoresSafeArea(edges: [.horizontal, .bottom])
#endif
        }
#if os(tvOS)
        .padding(.top, ChallengesLayout.topContentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onExitCommand(perform: onExitCommand)
#elseif os(iOS) || os(macOS)
        .padding(.top, ChallengesLayout.verticalContentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: ChallengesLayout.minimumWidth, minHeight: ChallengesLayout.minimumHeight)
#else
        .frame(maxWidth: ChallengesLayout.contentMaxWidth)
        .padding(.horizontal, ChallengesLayout.horizontalContentPadding)
        .padding(.vertical, ChallengesLayout.verticalContentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: ChallengesLayout.minimumWidth, minHeight: ChallengesLayout.minimumHeight)
#endif
        .background(Color.gameForeground)
    }
}

private extension ChallengesView {
    @ViewBuilder
    var header: some View {
#if os(tvOS)
        HStack(alignment: .firstTextBaseline, spacing: ChallengesLayout.headerSpacing) {
            title

            Spacer()

            progress
        }
#else
        VStack(alignment: .leading, spacing: ChallengesLayout.headerSpacing) {
            HStack {
                title

                Spacer()

                Button("Done".localized) {
                    dismiss()
                }
                .buttonStyle(GameButton())
            }

            progress
        }
#endif
    }

    var title: some View {
        Text("Challenges.Title".localized)
            .font(ChallengesLayout.titleFont)
            .foregroundColor(.labelDark)
    }

    var progress: some View {
        Text(
            String(
                format: "Challenges.Progress".localized,
                store.completedCount,
                store.challenges.count
            )
        )
        .font(ChallengesLayout.progressFont)
        .foregroundColor(.labelDark)
    }
}

private struct ChallengeRow: View {
    let challenge: Challenge
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: ChallengesLayout.rowSpacing) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: ChallengesLayout.statusIconSize, weight: .semibold))
                .foregroundColor(isCompleted ? .accentColor : .labelLight2)
                .frame(width: ChallengesLayout.statusIconFrame)

            VStack(alignment: .leading, spacing: ChallengesLayout.textSpacing) {
                Text(challenge.title)
                    .font(ChallengesLayout.rowTitleFont)
                    .foregroundColor(.labelLight)
                    .lineLimit(1)

                Text(challenge.description)
                    .font(ChallengesLayout.rowDescriptionFont)
                    .foregroundColor(.labelLight2)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(ChallengesLayout.rowPadding)
        .frame(maxWidth: .infinity, minHeight: ChallengesLayout.rowHeight, alignment: .leading)
        .background(Color.fieldForeground.opacity(isCompleted ? 1 : 0.72))
        .cornerRadius(ChallengesLayout.cornerRadius)
#if os(tvOS)
        .tvFocusableRow(cornerRadius: ChallengesLayout.cornerRadius)
#endif
    }
}

private enum ChallengesLayout {
    static let cornerRadius: CGFloat = 8

#if os(tvOS)
    static let contentMaxWidth: CGFloat = 1_300
    static let headerHorizontalPadding: CGFloat = 72
    static let topContentPadding: CGFloat = 24
    static let scrollContentHorizontalPadding: CGFloat = 72
    static let scrollContentVerticalPadding: CGFloat = 32
    static let minimumWidth: CGFloat? = nil
    static let minimumHeight: CGFloat? = nil
    static let sectionSpacing: CGFloat = 36
    static let itemSpacing: CGFloat = 16
    static let headerSpacing: CGFloat = 24
    static let rowSpacing: CGFloat = 16
    static let textSpacing: CGFloat = 6
    static let rowPadding: CGFloat = 18
    static let rowHeight: CGFloat = 116
    static let statusIconSize: CGFloat = 34
    static let statusIconFrame: CGFloat = 42
    static let titleFont = Font.largeTitle.bold()
    static let progressFont = Font.title2.bold()
    static let rowTitleFont = Font.headline
    static let rowDescriptionFont = Font.body
    static let columns = [GridItem(.flexible())]
#else
    static let contentMaxWidth: CGFloat = 720
    static let horizontalContentPadding: CGFloat = 20
    static let verticalContentPadding: CGFloat = 20
    static let scrollContentBottomPadding: CGFloat = 20
    static let minimumWidth: CGFloat? = 320
    static let minimumHeight: CGFloat? = 500
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let headerSpacing: CGFloat = 12
    static let rowSpacing: CGFloat = 14
    static let textSpacing: CGFloat = 5
    static let rowPadding: CGFloat = 16
    static let rowHeight: CGFloat = 88
    static let statusIconSize: CGFloat = 28
    static let statusIconFrame: CGFloat = 34
    static let titleFont = Font.title.bold()
    static let progressFont = Font.headline
    static let rowTitleFont = Font.headline
    static let rowDescriptionFont = Font.subheadline
    static let columns = [GridItem(.flexible())]
#endif
}

struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        let game = GameModel()
        ChallengesView(store: ChallengeStore(game: game))
    }
}
