//
//  ChallengeStore.swift
//  2048
//

import Combine
import Foundation

final class ChallengeStore: ObservableObject {
    let challenges: [Challenge]

    @Published private(set) var completedChallengeIDs: Set<String>
    @Published private(set) var presentedAchievement: Challenge?

    private let achievementReporter: AchievementReporting
    private var pendingAchievements: [Challenge] = []
    private var progressObservation: AnyCancellable?
    private var toastDismissalWorkItem: DispatchWorkItem?

    var completedCount: Int {
        challenges.filter(isCompleted).count
    }

    init(
        game: GameModel,
        challenges: [Challenge] = ChallengeCatalog.all,
        achievementReporter: AchievementReporting = GameCenterService.shared
    ) {
        self.challenges = challenges
        self.achievementReporter = achievementReporter
        completedChallengeIDs = ChallengeRepository.completedChallengeIDs
        achievementReporter.submit(
            completedAchievementIDs: completedChallengeIDs,
            showsCompletionBanner: false
        )

        progressObservation = game.$progress
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.evaluate(progress)
            }
    }

    func isCompleted(_ challenge: Challenge) -> Bool {
        completedChallengeIDs.contains(challenge.id)
    }

    deinit {
        toastDismissalWorkItem?.cancel()
    }
}

private extension ChallengeStore {
    func evaluate(_ progress: GameProgress) {
        let newlyCompleted = challenges.filter {
            !completedChallengeIDs.contains($0.id) && $0.condition.isSatisfied(by: progress)
        }

        guard !newlyCompleted.isEmpty else {
            return
        }

        newlyCompleted.forEach { completedChallengeIDs.insert($0.id) }
        ChallengeRepository.completedChallengeIDs = completedChallengeIDs
        achievementReporter.submit(
            completedAchievementIDs: Set(newlyCompleted.map(\.id)),
            showsCompletionBanner: true
        )
        pendingAchievements.append(contentsOf: newlyCompleted)
        presentNextAchievement()
    }

    func presentNextAchievement() {
        guard presentedAchievement == nil, !pendingAchievements.isEmpty else {
            return
        }

        presentedAchievement = pendingAchievements.removeFirst()

        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissPresentedAchievement()
        }
        toastDismissalWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + AchievementToastTiming.displayDuration,
            execute: workItem
        )
    }

    func dismissPresentedAchievement() {
        toastDismissalWorkItem?.cancel()
        toastDismissalWorkItem = nil
        presentedAchievement = nil

        DispatchQueue.main.asyncAfter(
            deadline: .now() + AchievementToastTiming.transitionDuration
        ) { [weak self] in
            self?.presentNextAchievement()
        }
    }
}

enum AchievementToastTiming {
    static let displayDuration: TimeInterval = 3
    static let transitionDuration: TimeInterval = 0.25
}
