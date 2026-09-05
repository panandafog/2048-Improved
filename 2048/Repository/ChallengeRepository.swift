//
//  ChallengeRepository.swift
//  2048
//

import Foundation

enum ChallengeRepository {
    private static let defaults = UserDefaults.standard
    private static let completedChallengeIDsKey = "CompletedChallengeIDs"
    private static let pendingGameCenterBannerIDsKey = "PendingGameCenterBannerIDs"

    static var completedChallengeIDs: Set<String> {
        get {
            Set(defaults.stringArray(forKey: completedChallengeIDsKey) ?? [])
        }
        set {
            defaults.set(Array(newValue).sorted(), forKey: completedChallengeIDsKey)
        }
    }

    static var pendingGameCenterBannerIDs: Set<String> {
        get {
            Set(defaults.stringArray(forKey: pendingGameCenterBannerIDsKey) ?? [])
        }
        set {
            defaults.set(Array(newValue).sorted(), forKey: pendingGameCenterBannerIDsKey)
        }
    }
}
