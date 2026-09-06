//
//  GameMode.swift
//  2048
//

import Foundation

enum GameMode: String, CaseIterable, Hashable, Identifiable {
    case classic
    case anomaly

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .classic:
            return "GameMode.Classic".localized
        case .anomaly:
            return "GameMode.Anomaly".localized
        }
    }

    var systemImage: String {
        switch self {
        case .classic:
            return "square.grid.2x2.fill"
        case .anomaly:
            return "sparkles"
        }
    }
}

enum BoardSize: Int, CaseIterable, Hashable, Identifiable {
    case standard = 4
    case large = 5
    case extraLarge = 6

    var id: Int {
        rawValue
    }

    var title: String {
        String(
            format: "BoardSize.Format".localized,
            rawValue,
            rawValue
        )
    }
}

struct GameConfiguration: Hashable {
    let mode: GameMode
    let boardSize: BoardSize

    static let standard = GameConfiguration(
        mode: .classic,
        boardSize: .standard
    )
}

enum AnomalyKind: String, CaseIterable, Identifiable {
    case wild
    case frozen
    case bomb
    case power
    case stone

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .wild:
            return "Anomaly.Wild".localized
        case .frozen:
            return "Anomaly.Frozen".localized
        case .bomb:
            return "Anomaly.Bomb".localized
        case .power:
            return "Anomaly.Power".localized
        case .stone:
            return "Anomaly.Stone".localized
        }
    }

    var systemImage: String {
        switch self {
        case .wild:
            return "sparkles"
        case .frozen:
            return "snowflake"
        case .bomb:
            return "burst.fill"
        case .power:
            return "bolt.fill"
        case .stone:
            return "lock.fill"
        }
    }

    var description: String {
        switch self {
        case .wild:
            return "Anomaly.Wild.Description".localized
        case .frozen:
            return "Anomaly.Frozen.Description".localized
        case .bomb:
            return "Anomaly.Bomb.Description".localized
        case .power:
            return "Anomaly.Power.Description".localized
        case .stone:
            return "Anomaly.Stone.Description".localized
        }
    }
}

enum FieldCellKind: Equatable {
    case normal
    case wild
    case frozen(remainingMoves: Int)
    case bomb
    case power
    case stone(remainingMoves: Int)

    var isFrozen: Bool {
        if case .frozen = self {
            return true
        }

        return false
    }

    var isStone: Bool {
        if case .stone = self {
            return true
        }

        return false
    }

    var preventsMerging: Bool {
        isFrozen || isStone
    }
}
