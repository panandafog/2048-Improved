//
//  FieldCell.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import Foundation

class FieldCell: Identifiable, Hashable, ObservableObject {
    // MARK: - Identity
    
    let id = UUID()
    
    // MARK: - State
    
    @Published var value: Int
    @Published var kind: FieldCellKind
    var coordinate: Coordinate
    
    // MARK: - Lifecycle
    
    init(
        value: Int,
        coordinate: Coordinate,
        kind: FieldCellKind = .normal
    ) {
        self.value = value
        self.coordinate = coordinate
        self.kind = kind
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Equatable

extension FieldCell: Equatable {
    static func == (lhs: FieldCell, rhs: FieldCell) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Board

struct SampleBoardCell: Identifiable {
    let value: Int
    let coordinate: Coordinate
    let kind: FieldCellKind

    var id: Coordinate {
        coordinate
    }

    init(
        value: Int,
        row: Int,
        column: Int,
        kind: FieldCellKind = .normal
    ) {
        self.value = value
        coordinate = Coordinate(row: row, col: column)
        self.kind = kind
    }
}

enum SampleBoard {
    private static let values = [
        2, 2, 4, 4, 8, 8, 16, 16,
        32, 32, 64, 64, 128, 256, 512, 1024
    ]
    static func cells(fieldSize: Int, mode: GameMode) -> [SampleBoardCell] {
        let normalCells = (0 ..< fieldSize).flatMap { row in
            (0 ..< fieldSize).compactMap { column -> SampleBoardCell? in
                let flatIndex = row * fieldSize + column
                let emptyColumn = (row * 3 + 2) % fieldSize
                guard column != emptyColumn else {
                    return nil
                }

                return SampleBoardCell(
                    value: values[flatIndex % values.count],
                    row: row,
                    column: column
                )
            }
        }

        guard mode == .anomaly else {
            return normalCells
        }

        let lastIndex = fieldSize - 1
        let specialCells = [
            SampleBoardCell(value: 0, row: 0, column: 1, kind: .wild),
            SampleBoardCell(value: 4, row: 1, column: lastIndex - 1, kind: .bomb),
            SampleBoardCell(
                value: 64,
                row: fieldSize / 2,
                column: fieldSize / 2,
                kind: .frozen(remainingMoves: 5)
            ),
            SampleBoardCell(
                value: 16,
                row: lastIndex,
                column: lastIndex - 1,
                kind: .power
            ),
            SampleBoardCell(
                value: 128,
                row: lastIndex,
                column: 0,
                kind: .stone(remainingMoves: 4)
            )
        ]

        let replacedCoordinates = Set(specialCells.map(\.coordinate))
        return normalCells.filter {
            !replacedCoordinates.contains($0.coordinate)
        } + specialCells
    }
}
