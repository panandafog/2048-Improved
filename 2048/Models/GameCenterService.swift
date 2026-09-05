//
//  GameCenterService.swift
//  2048
//

import GameKit

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

protocol AchievementReporting: AnyObject {
    func submit(
        completedAchievementIDs: Set<String>,
        showsCompletionBanner: Bool
    )
}

final class GameCenterService: AchievementReporting {
    static let shared = GameCenterService()

    private var pendingAchievements: [String: Bool]
    private var hasStartedAuthentication = false
    private var isReporting = false

    private init() {
        pendingAchievements = Dictionary(
            uniqueKeysWithValues: ChallengeRepository.pendingGameCenterBannerIDs.map {
                ($0, true)
            }
        )
    }

    func authenticate() {
        guard !hasStartedAuthentication else {
            return
        }

        hasStartedAuthentication = true
        let localPlayer = GKLocalPlayer.local

        localPlayer.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                if let viewController {
                    self.presentAuthentication(viewController)
                    return
                }

                guard error == nil, localPlayer.isAuthenticated else {
                    return
                }

                self.submitPendingAchievements()
            }
        }
    }

    func submit(
        completedAchievementIDs: Set<String>,
        showsCompletionBanner: Bool
    ) {
        guard !completedAchievementIDs.isEmpty else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            completedAchievementIDs.forEach { identifier in
                let wasShowingBanner = self?.pendingAchievements[identifier] ?? false
                self?.pendingAchievements[identifier] = wasShowingBanner || showsCompletionBanner
            }
            self?.persistPendingBanners()
            self?.submitPendingAchievements()
        }
    }
}

private extension GameCenterService {
    func submitPendingAchievements() {
        guard
            GKLocalPlayer.local.isAuthenticated,
            !isReporting,
            !pendingAchievements.isEmpty
        else {
            return
        }

        isReporting = true
        let requestedAchievements = pendingAchievements

        GKAchievement.loadAchievements { [weak self] achievements, _ in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                let completedIDs = Set(
                    achievements?
                        .filter(\.isCompleted)
                        .map(\.identifier) ?? []
                )
                completedIDs.forEach { self.pendingAchievements.removeValue(forKey: $0) }
                self.persistPendingBanners()

                let achievementsToReport = requestedAchievements.filter {
                    !completedIDs.contains($0.key)
                }
                guard !achievementsToReport.isEmpty else {
                    self.isReporting = false
                    self.submitPendingAchievements()
                    return
                }

                self.reportAchievements(achievementsToReport)
            }
        }
    }

    func reportAchievements(_ pendingAchievements: [String: Bool]) {
        let achievements = pendingAchievements.map { identifier, showsCompletionBanner in
            let achievement = GKAchievement(identifier: identifier)
            achievement.percentComplete = 100
            achievement.showsCompletionBanner = showsCompletionBanner
            return achievement
        }

        GKAchievement.report(achievements) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                if error == nil {
                    pendingAchievements.keys.forEach {
                        self.pendingAchievements.removeValue(forKey: $0)
                    }
                    self.persistPendingBanners()
                }

                self.isReporting = false

                if error == nil {
                    self.submitPendingAchievements()
                }
            }
        }
    }

    func persistPendingBanners() {
        ChallengeRepository.pendingGameCenterBannerIDs = Set(
            pendingAchievements
                .filter(\.value)
                .map(\.key)
        )
    }

#if canImport(UIKit)
    func presentAuthentication(_ viewController: UIViewController) {
        guard viewController.presentingViewController == nil else {
            return
        }

        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)

        guard var presenter = window?.rootViewController else {
            return
        }

        while let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }

        presenter.present(viewController, animated: true)
    }
#elseif canImport(AppKit)
    func presentAuthentication(_ viewController: NSViewController) {
        guard
            viewController.presentingViewController == nil,
            let presenter = NSApplication.shared.keyWindow?.contentViewController
        else {
            return
        }

        presenter.presentAsModalWindow(viewController)
    }
#endif
}
