//
//  ChallengeStore.swift
//  2048
//

import Combine
import Foundation

final class ChallengeStore: ObservableObject {
    let challenges: [Challenge]

    @Published private(set) var completedChallengeIDs: Set<String>
    @Published var presentedCompletion: Challenge?

    private weak var game: GameModel?
    private var pendingCompletions: [Challenge] = []
    private var progressObservation: AnyCancellable?
    private var gameAlertObservation: AnyCancellable?

    var completedCount: Int {
        challenges.filter(isCompleted).count
    }

    init(game: GameModel, challenges: [Challenge] = ChallengeCatalog.all) {
        self.game = game
        self.challenges = challenges
        completedChallengeIDs = ChallengeRepository.completedChallengeIDs

        progressObservation = game.$progress
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.evaluate(progress)
            }

        gameAlertObservation = Publishers.CombineLatest3(
            game.$victory,
            game.$lose,
            game.$newGameRequested
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] alertState in
            guard !alertState.0, !alertState.1, !alertState.2 else {
                return
            }

            DispatchQueue.main.async {
                self?.presentNextCompletion()
            }
        }
    }

    func isCompleted(_ challenge: Challenge) -> Bool {
        completedChallengeIDs.contains(challenge.id)
    }

    func dismissPresentedCompletion() {
        presentedCompletion = nil
        DispatchQueue.main.async { [weak self] in
            self?.presentNextCompletion()
        }
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
        pendingCompletions.append(contentsOf: newlyCompleted)
        presentNextCompletion()
    }

    func presentNextCompletion() {
        let isGameAlertPresented = game.map {
            $0.victory || $0.lose || $0.newGameRequested
        } ?? false

        guard
            !isGameAlertPresented,
            presentedCompletion == nil,
            !pendingCompletions.isEmpty
        else {
            return
        }

        presentedCompletion = pendingCompletions.removeFirst()
    }
}
