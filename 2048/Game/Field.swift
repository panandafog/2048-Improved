//
//  Field.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import Foundation

class Field: ObservableObject {
    
    private (set) var cells = Set<FieldCell>()
    let fieldSize: Int
    
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
    
    init(fieldSize: Int) {
        self.fieldSize = fieldSize
    }
    
    func getCell(at coordinate: Coordinate) -> FieldCell? {
        cells.first { $0.coordinate == coordinate }
    }
    
    func setCell(_ newCell: FieldCell) {
        if let index = cells.firstIndex(where: {
            $0.coordinate == newCell.coordinate ||
            $0.id == newCell.id
        }) {
            cells.remove(at: index)
        }
        cells.insert(newCell)
        
        objectWillChange.send()
    }
    
    func generateNewCell() throws {
        guard let coordinate = emptyCoordinates.randomElement() else {
            throw GameError.noFreeSpace
        }
        setCell(FieldCell(value: newElementValue, coordinate: coordinate))
        
        objectWillChange.send()
    }
    
    func move(_ direction: MoveDirection) throws -> Int {
        guard let mergedSum = moveCells(direction) else {
            throw GameError.cantMove
        }
        
        try generateNewCell()
        objectWillChange.send()
        return mergedSum
    }
    
    func reset() {
        cells = []
    }
    
    private func moveCells(_ direction: MoveDirection) -> Int? {
        var moved = false
        var mergedSum = 0
        var mergedCellsIDs: Set<UUID> = []
        
        for firstIndex in 0 ..< fieldSize {
            
            var secondIndexSequence: any Sequence
            if direction.isStraight {
                secondIndexSequence = 1 ..< fieldSize
            } else {
                secondIndexSequence = stride(from: fieldSize - 2, to: -1, by: -1)
            }
            
            for secondIndex in secondIndexSequence {
                let secondIndex = secondIndex as! Int
                
                let currentCoordinate: Coordinate
                if direction.isVertical {
                    currentCoordinate = .init(row: secondIndex, col: firstIndex)
                } else {
                    currentCoordinate = .init(row: firstIndex, col: secondIndex)
                }
                
                if let currentCell = getCell(at: currentCoordinate) {
                    
                    var searchIndexSequence: any Sequence
                    if direction.isStraight {
                        searchIndexSequence = stride(from: secondIndex - 1, to: -1, by: -1)
                    } else {
                        searchIndexSequence = secondIndex + 1 ..< fieldSize
                    }
                    
                    for searchIndex in searchIndexSequence {
                        let searchIndex = searchIndex as! Int
                        
                        var searchCell: FieldCell?
                        if direction.isVertical {
                            searchCell = getCell(at: .init(row: searchIndex, col: firstIndex))
                        } else {
                            searchCell = getCell(at: .init(row: firstIndex, col: searchIndex))
                        }
                        
                        if let searchCell = searchCell {
                            
                            if searchCell.value == currentCell.value
                                && !mergedCellsIDs.contains(currentCell.id)
                                && !mergedCellsIDs.contains(searchCell.id) {
                                // merge cells
                                cells.remove(searchCell)
                                currentCell.value *= 2
                                currentCell.coordinate = searchCell.coordinate
                                mergedCellsIDs.insert(currentCell.id)
                                moved = true
                                mergedSum += currentCell.value
                            } else {
                                // stop searching
                                break
                            }
                            
                        } else if searchCell == nil {
                            // move cell
                            if direction.isVertical {
                                currentCell.coordinate = .init(row: searchIndex, col: firstIndex)
                            } else {
                                currentCell.coordinate = .init(row: firstIndex, col: searchIndex)
                            }
                            moved = true
                        }
                    }
                }
            }
        }
        return moved ? mergedSum : nil
    }
    
//    private func moveUp() -> Bool {
//        var moved = false
//        for colInd in 0 ..< fieldSize {
//            for currentRowInd in 1 ..< fieldSize {
//                if let currentCell = getCell(at: .init(row: currentRowInd, col: colInd)) {
//                    for searchRowInd in stride(from: currentRowInd - 1, to: -1, by: -1) {
//                        let searchCell = getCell(at: .init(row: searchRowInd, col: colInd))
//                        if let searchCell = searchCell,
//                           searchCell.value == currentCell.value {
//                            cells.remove(searchCell)
//                            currentCell.value *= 2
//                            currentCell.coordinate = searchCell.coordinate
//                            moved = true
//                        } else if searchCell == nil {
//                            currentCell.coordinate = .init(row: searchRowInd, col: colInd)
//                            moved = true
//                        }
//                    }
//                }
//            }
//        }
//        return moved
//    }
//
//    private func moveDown() -> Bool {
//        var moved = false
//        for colInd in 0 ..< fieldSize {
//            for currentRowInd in stride(from: fieldSize - 2, to: -1, by: -1) {
//                if let currentCell = getCell(at: .init(row: currentRowInd, col: colInd)) {
//                    for searchRowInd in currentRowInd + 1 ..< fieldSize {
//                        let searchCell = getCell(at: .init(row: searchRowInd, col: colInd))
//                        if let searchCell = searchCell,
//                           searchCell.value == currentCell.value {
//                            cells.remove(searchCell)
//                            currentCell.value *= 2
//                            currentCell.coordinate = searchCell.coordinate
//                            moved = true
//                        } else if searchCell == nil {
//                            currentCell.coordinate = .init(row: searchRowInd, col: colInd)
//                            moved = true
//                        }
//                    }
//                }
//            }
//        }
//        return moved
//    }
//
//    private func moveLeft() -> Bool {
//        var moved = false
//        for rowInd in 0 ..< fieldSize {
//            for currentColInd in 1 ..< fieldSize {
//                if let currentCell = getCell(at: .init(row: rowInd, col: currentColInd)) {
//                    for searchColInd in stride(from: currentColInd - 1, to: -1, by: -1) {
//                        let searchCell = getCell(at: .init(row: rowInd, col: searchColInd))
//                        if let searchCell = searchCell,
//                           searchCell.value == currentCell.value {
//                            cells.remove(searchCell)
//                            currentCell.value *= 2
//                            currentCell.coordinate = searchCell.coordinate
//                            moved = true
//                        } else if searchCell == nil {
//                            currentCell.coordinate = .init(row: rowInd, col: searchColInd)
//                            moved = true
//                        }
//                    }
//                }
//            }
//        }
//        return moved
//    }
//
//    private func moveRight() -> Bool {
//        var moved = false
//        for rowInd in 0 ..< fieldSize {
//            for currentColInd in stride(from: fieldSize - 2, to: -1, by: -1) {
//                if let currentCell = getCell(at: .init(row: rowInd, col: currentColInd)) {
//                    for searchColInd in currentColInd + 1 ..< fieldSize {
//                        let searchCell = getCell(at: .init(row: rowInd, col: searchColInd))
//                        if let searchCell = searchCell,
//                           searchCell.value == currentCell.value {
//                            cells.remove(searchCell)
//                            currentCell.value *= 2
//                            currentCell.coordinate = searchCell.coordinate
//                            moved = true
//                        } else if searchCell == nil {
//                            currentCell.coordinate = .init(row: rowInd, col: searchColInd)
//                            moved = true
//                        }
//                    }
//                }
//            }
//        }
//        return moved
//    }
}
