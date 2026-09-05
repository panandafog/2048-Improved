//
//  AchievementToast.swift
//  2048
//

import SwiftUI

private struct AchievementToast: View {
    let achievement: Challenge

    var body: some View {
        HStack(spacing: AchievementToastLayout.spacing) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: AchievementToastLayout.iconSize, weight: .semibold))
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: AchievementToastLayout.textSpacing) {
                Text("Toast.AchievementUnlocked".localized)
                    .font(AchievementToastLayout.captionFont)
                    .foregroundColor(.labelLight2)

                Text(achievement.title)
                    .font(AchievementToastLayout.titleFont)
                    .foregroundColor(.labelLight)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, AchievementToastLayout.verticalPadding)
        .padding(.horizontal, AchievementToastLayout.horizontalPadding)
        .frame(maxWidth: AchievementToastLayout.maximumWidth, alignment: .leading)
        .background(Color.fieldForeground)
        .overlay {
            RoundedRectangle(cornerRadius: AchievementToastLayout.cornerRadius)
                .strokeBorder(Color.accentColor.opacity(0.8), lineWidth: 2)
        }
        .cornerRadius(AchievementToastLayout.cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 12, y: 5)
        .accessibilityElement(children: .combine)
    }
}

private struct AchievementToastModifier: ViewModifier {
    @ObservedObject var store: ChallengeStore

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let achievement = store.presentedAchievement {
                    AchievementToast(achievement: achievement)
                        .padding(.horizontal, AchievementToastLayout.screenPadding)
                        .padding(.bottom, AchievementToastLayout.bottomPadding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .allowsHitTesting(false)
                        .zIndex(1)
                }
            }
            .animation(
                .easeOut(duration: AchievementToastTiming.transitionDuration),
                value: store.presentedAchievement
            )
    }
}

extension View {
    func achievementToast(store: ChallengeStore) -> some View {
        modifier(AchievementToastModifier(store: store))
    }
}

private enum AchievementToastLayout {
    static let cornerRadius: CGFloat = 8

#if os(tvOS)
    static let spacing: CGFloat = 18
    static let textSpacing: CGFloat = 4
    static let iconSize: CGFloat = 34
    static let verticalPadding: CGFloat = 18
    static let horizontalPadding: CGFloat = 22
    static let maximumWidth: CGFloat = 680
    static let screenPadding: CGFloat = 72
    static let bottomPadding: CGFloat = 52
    static let captionFont = Font.callout.bold()
    static let titleFont = Font.title3.bold()
#else
    static let spacing: CGFloat = 12
    static let textSpacing: CGFloat = 2
    static let iconSize: CGFloat = 24
    static let verticalPadding: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let maximumWidth: CGFloat = 380
    static let screenPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 16
    static let captionFont = Font.caption.bold()
    static let titleFont = Font.headline
#endif
}
