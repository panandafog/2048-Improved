//
//  Field.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import Foundation

struct FieldMoveResult {
    let score: Int
    let highestTile: Int
    let didWin: Bool
}

final class Field: ObservableObject {
    // MARK: - State

    private(set) var cells = Set<FieldCell>()
    let fieldSize: Int
    let winValue: Int
    let mode: GameMode

    private var anomalyDeck: [AnomalyKind] = []
    private var lastAnomalyKind: AnomalyKind?

    // MARK: - Derived State

    var emptyCoordinates: [Coordinate] {
        var coordinates: [Coordinate] = []

        for row in 0 ..< fieldSize {
            for col in 0 ..< fieldSize where getCell(at: Coordinate(row: row, col: col)) == nil {
                coordinates.append(Coordinate(row: row, col: col))
            }
        }

        return coordinates
    }

    var newElementValue: Int {
        Int(pow(2.0, Double(Int.random(in: 1...2))))
    }

    var highestTile: Int {
        cells.map(\.value).max() ?? 0
    }

    var canMove: Bool {
        let neighborOffsets = [
            Coordinate(row: -1, col: 0),
            Coordinate(row: 1, col: 0),
            Coordinate(row: 0, col: -1),
            Coordinate(row: 0, col: 1)
        ]

        for cell in cells where !cell.kind.isStone {
            for offset in neighborOffsets {
                let neighborCoordinate = Coordinate(
                    row: cell.coordinate.row + offset.row,
                    col: cell.coordinate.col + offset.col
                )

                guard isInsideField(neighborCoordinate) else {
                    continue
                }

                guard let neighbor = getCell(at: neighborCoordinate) else {
                    return true
                }

                if canMerge(cell, with: neighbor) {
                    return true
                }
            }
        }

        return false
    }

    var nextAnomalyKind: AnomalyKind? {
        mode == .anomaly ? anomalyDeck.first : nil
    }

    // MARK: - Lifecycle

    init(fieldSize: Int, winValue: Int, mode: GameMode = .classic) {
        self.fieldSize = fieldSize
        self.winValue = winValue
        self.mode = mode
        refillAnomalyDeckIfNeeded()
    }

    // MARK: - Cell Access

    func getCell(at coordinate: Coordinate) -> FieldCell? {
        cells.first { $0.coordinate == coordinate }
    }

    func isInsideField(_ coordinate: Coordinate) -> Bool {
        (0 ..< fieldSize).contains(coordinate.row)
            && (0 ..< fieldSize).contains(coordinate.col)
    }

    func setCell(_ newCell: FieldCell) {
        if let index = cells.firstIndex(where: {
            $0.coordinate == newCell.coordinate || $0.id == newCell.id
        }) {
            cells.remove(at: index)
        }

        cells.insert(newCell)
        notifyChange()
    }

    // MARK: - Game Flow

    func generateNewCell(isAnomaly: Bool = false) throws {
        guard let coordinate = emptyCoordinates.randomElement() else {
            throw GameError.noFreeSpace
        }

        let cell = isAnomaly ? makeAnomalyCell(at: coordinate) : makeNormalCell(at: coordinate)
        setCell(cell)
    }

    func move(_ direction: MoveDirection, generatesAnomaly: Bool = false) throws -> FieldMoveResult {
        let movement = try moveCells(direction)
        advanceTimedCells()
        explodeBombs(at: movement.explosionCenters)

        let didWin = movement.highestMergedValue >= winValue
        if didWin {
            notifyChange()
        } else {
            try generateCellsAfterMove(
                includesAnomaly: generatesAnomaly && mode == .anomaly
            )
        }

        return FieldMoveResult(
            score: movement.score,
            highestTile: highestTile,
            didWin: didWin
        )
    }

    func reset() {
        cells = []
        anomalyDeck = []
        lastAnomalyKind = nil
        refillAnomalyDeckIfNeeded()
        notifyChange()
    }
}

private extension Field {
    struct MovementResult {
        var moved = false
        var score = 0
        var highestMergedValue = 0
        var explosionCenters: Set<Coordinate> = []
    }

    struct MergeResult {
        let value: Int
        let explodes: Bool
    }

    // MARK: - Movement

    func moveCells(_ direction: MoveDirection) throws -> MovementResult {
        var result = MovementResult()

        for lineIndex in 0 ..< fieldSize {
            let coordinates = coordinates(for: lineIndex, direction: direction)

            for segment in movableSegments(in: coordinates) {
                let lineCells = segment.compactMap(getCell)
                move(lineCells, to: segment, result: &result)
            }
        }

        guard result.moved else {
            throw GameError.cantMove
        }

        return result
    }

    func move(
        _ lineCells: [FieldCell],
        to coordinates: [Coordinate],
        result: inout MovementResult
    ) {
        var sourceIndex = 0
        var destinationIndex = 0

        while sourceIndex < lineCells.count {
            let leadingCell = lineCells[sourceIndex]

            if sourceIndex + 1 < lineCells.count {
                let trailingCell = lineCells[sourceIndex + 1]

                if let merge = mergeResult(for: leadingCell, and: trailingCell) {
                    cells.remove(leadingCell)
                    trailingCell.value = merge.value
                    trailingCell.kind = .normal
                    updateCoordinate(
                        of: trailingCell,
                        to: coordinates[destinationIndex],
                        moved: &result.moved
                    )

                    result.moved = true
                    result.score += merge.value
                    result.highestMergedValue = max(result.highestMergedValue, merge.value)

                    if merge.explodes {
                        result.explosionCenters.insert(coordinates[destinationIndex])
                    }

                    sourceIndex += 2
                    destinationIndex += 1
                    continue
                }
            }

            updateCoordinate(
                of: leadingCell,
                to: coordinates[destinationIndex],
                moved: &result.moved
            )
            sourceIndex += 1
            destinationIndex += 1
        }
    }

    func updateCoordinate(
        of cell: FieldCell,
        to coordinate: Coordinate,
        moved: inout Bool
    ) {
        if cell.coordinate != coordinate {
            cell.coordinate = coordinate
            moved = true
        }
    }

    func coordinates(for lineIndex: Int, direction: MoveDirection) -> [Coordinate] {
        let indices: [Int]

        if direction.isStraight {
            indices = Array(0 ..< fieldSize)
        } else {
            indices = Array((0 ..< fieldSize).reversed())
        }

        return indices.map { index in
            if direction.isVertical {
                return Coordinate(row: index, col: lineIndex)
            }

            return Coordinate(row: lineIndex, col: index)
        }
    }

    func movableSegments(in coordinates: [Coordinate]) -> [[Coordinate]] {
        var segments: [[Coordinate]] = []
        var currentSegment: [Coordinate] = []

        for coordinate in coordinates {
            if getCell(at: coordinate)?.kind.isStone == true {
                if !currentSegment.isEmpty {
                    segments.append(currentSegment)
                    currentSegment = []
                }
            } else {
                currentSegment.append(coordinate)
            }
        }

        if !currentSegment.isEmpty {
            segments.append(currentSegment)
        }

        return segments
    }

    // MARK: - Merging

    func canMerge(_ first: FieldCell, with second: FieldCell) -> Bool {
        mergeResult(for: first, and: second) != nil
    }

    func mergeResult(for first: FieldCell, and second: FieldCell) -> MergeResult? {
        guard !first.kind.preventsMerging, !second.kind.preventsMerging else {
            return nil
        }

        let explodes = first.kind == .bomb || second.kind == .bomb
        let multiplier = first.kind == .power || second.kind == .power ? 4 : 2

        if first.kind == .wild, second.kind == .wild {
            return MergeResult(value: 4, explodes: false)
        }

        if first.kind == .wild {
            return MergeResult(value: second.value * multiplier, explodes: explodes)
        }

        if second.kind == .wild {
            return MergeResult(value: first.value * multiplier, explodes: explodes)
        }

        guard first.value == second.value else {
            return nil
        }

        return MergeResult(value: first.value * multiplier, explodes: explodes)
    }

    // MARK: - Effects

    func advanceTimedCells() {
        cells.forEach { cell in
            switch cell.kind {
            case .frozen(let remainingMoves):
                cell.kind = remainingMoves <= 1
                    ? .normal
                    : .frozen(remainingMoves: remainingMoves - 1)
            case .stone(let remainingMoves):
                cell.kind = remainingMoves <= 1
                    ? .normal
                    : .stone(remainingMoves: remainingMoves - 1)
            default:
                break
            }
        }
    }

    func explodeBombs(at centers: Set<Coordinate>) {
        guard !centers.isEmpty else {
            return
        }

        let explodedCells = cells.filter { cell in
            centers.contains { center in
                let rowDistance = abs(cell.coordinate.row - center.row)
                let columnDistance = abs(cell.coordinate.col - center.col)
                return rowDistance + columnDistance == 1
            }
        }

        explodedCells.forEach { cells.remove($0) }
    }

    // MARK: - Generation

    var generatedCellCountPerMove: Int {
        max(1, fieldSize - 3)
    }

    func generateCellsAfterMove(includesAnomaly: Bool) throws {
        let generatedCellCount = min(
            generatedCellCountPerMove,
            emptyCoordinates.count
        )

        for index in 0 ..< generatedCellCount {
            try generateNewCell(isAnomaly: includesAnomaly && index == 0)
        }
    }

    func makeNormalCell(at coordinate: Coordinate) -> FieldCell {
        FieldCell(value: newElementValue, coordinate: coordinate)
    }

    func makeAnomalyCell(at coordinate: Coordinate) -> FieldCell {
        let kind = takeNextAnomalyKind()

        switch kind {
        case .wild:
            return FieldCell(value: 0, coordinate: coordinate, kind: .wild)
        case .frozen:
            return FieldCell(
                value: newElementValue,
                coordinate: coordinate,
                kind: .frozen(remainingMoves: anomalyCountdown)
            )
        case .bomb:
            return FieldCell(value: newElementValue, coordinate: coordinate, kind: .bomb)
        case .power:
            return FieldCell(value: powerValue, coordinate: coordinate, kind: .power)
        case .stone:
            return FieldCell(
                value: newElementValue,
                coordinate: coordinate,
                kind: .stone(remainingMoves: anomalyCountdown)
            )
        }
    }

    var anomalyCountdown: Int {
        Int.random(in: 3 ... 8)
    }

    var powerValue: Int {
        Bool.random() ? 8 : 16
    }

    func takeNextAnomalyKind() -> AnomalyKind {
        refillAnomalyDeckIfNeeded()
        let kind = anomalyDeck.removeFirst()
        lastAnomalyKind = kind
        refillAnomalyDeckIfNeeded()
        return kind
    }

    func refillAnomalyDeckIfNeeded() {
        guard mode == .anomaly, anomalyDeck.isEmpty else {
            return
        }

        var newDeck = AnomalyKind.allCases.shuffled()
        if newDeck.first == lastAnomalyKind, newDeck.count > 1 {
            newDeck.swapAt(0, 1)
        }

        anomalyDeck = newDeck
    }

    // MARK: - Observation

    func notifyChange() {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
