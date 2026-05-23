//
//  FieldView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct FieldView: View {
    static let indent: CGFloat = 10
    
    private static let moveAnimationDuration: TimeInterval = 0.18
    private static let moveAnimation = Animation.easeOut(duration: moveAnimationDuration)
    private static let mergeAnimation = Animation.easeOut(duration: 0.14)
    private static let appearanceAnimation = Animation.easeOut(duration: 0.14)
    
    @ObservedObject var game: GameModel
    // FieldCell is mutable, so the view keeps render snapshots for reliable position animations.
    @State private var cells: [RenderedFieldCell] = []
    @State private var pendingValueUpdates: [UUID: DispatchWorkItem] = [:]
    @State private var pendingCellInsertions: [UUID: DispatchWorkItem] = [:]
    @State private var pendingAppearanceResets: [UUID: DispatchWorkItem] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            let allIndents = FieldView.indent * CGFloat(game.field.fieldSize + 1)
            let cellWidth = (geometry.size.width - allIndents) / CGFloat(game.field.fieldSize)
            let cellHeight = (geometry.size.height - allIndents) / CGFloat(game.field.fieldSize)
            
            ForEach(0 ..< game.field.fieldSize, id: \.self) { rowInd in
                ForEach(0 ..< game.field.fieldSize, id: \.self) { colInd in
                    FieldCellView(value: nil)
                        .position(
                            x: Self.indent * CGFloat(colInd + 1) + cellWidth * (CGFloat(colInd) + 0.5),
                            y: Self.indent * CGFloat(rowInd + 1) + cellHeight * (CGFloat(rowInd) + 0.5)
                        )
                        .frame(width: cellWidth, height: cellHeight)
                }
            }
            
            ForEach(cells) { cell in
                let rowInd = cell.coordinate.row
                let colInd = cell.coordinate.col
                FieldCellView(value: cell.value)
                    .compositingGroup()
                    .frame(width: cellWidth, height: cellHeight)
                    .position(
                        x: Self.indent * CGFloat(colInd + 1) + cellWidth * (CGFloat(colInd) + 0.5),
                        y: Self.indent * CGFloat(rowInd + 1) + cellHeight * (CGFloat(rowInd) + 0.5)
                    )
                    .opacity(cell.appearsWithAnimation ? 0 : 1)
                    .transition(.identity)
            }
            .onReceive(game.field.objectWillChange) { _ in
                updateCells(with: game.field.cells.map { FieldCellSnapshot(cell: $0) })
            }
        }
        .background(Color.fieldForeground)
        .cornerRadius(10)
    }
}

private extension FieldView {
    func updateCells(with snapshots: [FieldCellSnapshot]) {
        cancelPendingCellInsertions()
        cancelPendingValueUpdates()
        cancelPendingAppearanceResets()
        
        var delayedValueUpdates: [(id: UUID, value: Int)] = []
        var appearingCells: [RenderedFieldCell] = []
        let currentCells = Dictionary(uniqueKeysWithValues: cells.map { ($0.id, $0) })
        let hasMovingCells = snapshots.contains { snapshot in
            guard let currentCell = currentCells[snapshot.id] else {
                return false
            }
            
            return currentCell.coordinate != snapshot.coordinate
        }
        
        let nextCells = snapshots.compactMap { snapshot -> RenderedFieldCell? in
            guard let currentCell = currentCells[snapshot.id] else {
                let appearingCell = RenderedFieldCell(
                    snapshot: snapshot,
                    appearsWithAnimation: true
                )
                
                if hasMovingCells {
                    appearingCells.append(appearingCell)
                    return nil
                }
                
                return appearingCell
            }
            
            guard
                currentCell.value != snapshot.value,
                currentCell.coordinate != snapshot.coordinate
            else {
                return RenderedFieldCell(snapshot: snapshot)
            }
            
            delayedValueUpdates.append((snapshot.id, snapshot.value))
            
            // Keep the old value while the tile is moving; SwiftUI otherwise swaps
            // Text views before the position animation reaches the destination.
            return RenderedFieldCell(
                id: snapshot.id,
                value: currentCell.value,
                coordinate: snapshot.coordinate
            )
        }
        
        if hasMovingCells {
            withAnimation(Self.moveAnimation) {
                cells = nextCells
            }
        } else {
            setCellsWithoutAnimation(nextCells)
        }
        
        if hasMovingCells {
            scheduleAppearingCells(appearingCells)
        } else {
            scheduleAppearanceReset(for: nextCells.filter(\.appearsWithAnimation).map(\.id))
        }
        
        delayedValueUpdates.forEach { update in
            let workItem = DispatchWorkItem {
                applyDelayedValue(update.value, to: update.id)
            }
            
            pendingValueUpdates[update.id] = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Self.moveAnimationDuration,
                execute: workItem
            )
        }
    }
    
    func setCellsWithoutAnimation(_ newCells: [RenderedFieldCell]) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            cells = newCells
        }
    }
    
    func scheduleAppearingCells(_ appearingCells: [RenderedFieldCell]) {
        guard !appearingCells.isEmpty else {
            return
        }
        
        let ids = appearingCells.map(\.id)
        let workItem = DispatchWorkItem {
            ids.forEach { pendingCellInsertions[$0] = nil }
            insertAppearingCells(appearingCells)
        }
        
        ids.forEach { pendingCellInsertions[$0] = workItem }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Self.moveAnimationDuration,
            execute: workItem
        )
    }
    
    func insertAppearingCells(_ appearingCells: [RenderedFieldCell]) {
        let existingIDs = Set(cells.map(\.id))
        let newCells = appearingCells.filter { !existingIDs.contains($0.id) }
        
        guard !newCells.isEmpty else {
            return
        }
        
        setCellsWithoutAnimation(cells + newCells)
        scheduleAppearanceReset(for: newCells.map(\.id))
    }
    
    func applyDelayedValue(_ value: Int, to id: UUID) {
        pendingValueUpdates[id] = nil
        
        guard let index = cells.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var updatedCells = cells
        updatedCells[index].value = value
        
        withAnimation(Self.mergeAnimation) {
            cells = updatedCells
        }
    }
    
    func scheduleAppearanceReset(for ids: [UUID]) {
        let ids = Array(Set(ids))
        guard !ids.isEmpty else {
            return
        }
        
        ids.forEach { pendingAppearanceResets[$0]?.cancel() }
        
        let workItem = DispatchWorkItem {
            ids.forEach { pendingAppearanceResets[$0] = nil }
            
            withAnimation(Self.appearanceAnimation) {
                resetAppearanceState(for: ids)
            }
        }
        
        ids.forEach { pendingAppearanceResets[$0] = workItem }
        DispatchQueue.main.async(execute: workItem)
    }
    
    func resetAppearanceState(for ids: [UUID]) {
        var updatedCells = cells
        var didUpdate = false
        
        for id in ids {
            guard let index = updatedCells.firstIndex(where: { $0.id == id }) else {
                continue
            }
            
            updatedCells[index].appearsWithAnimation = false
            didUpdate = true
        }
        
        guard didUpdate else {
            return
        }
        
        cells = updatedCells
    }
    
    func cancelPendingValueUpdates() {
        pendingValueUpdates.values.forEach { $0.cancel() }
        pendingValueUpdates = [:]
    }
    
    func cancelPendingCellInsertions() {
        pendingCellInsertions.values.forEach { $0.cancel() }
        pendingCellInsertions = [:]
    }
    
    func cancelPendingAppearanceResets() {
        pendingAppearanceResets.values.forEach { $0.cancel() }
        pendingAppearanceResets = [:]
    }
}

private struct RenderedFieldCell: Identifiable, Equatable {
    let id: UUID
    var value: Int
    var coordinate: Coordinate
    var appearsWithAnimation: Bool
    
    init(
        id: UUID,
        value: Int,
        coordinate: Coordinate,
        appearsWithAnimation: Bool = false
    ) {
        self.id = id
        self.value = value
        self.coordinate = coordinate
        self.appearsWithAnimation = appearsWithAnimation
    }
    
    init(snapshot: FieldCellSnapshot, appearsWithAnimation: Bool = false) {
        self.init(
            id: snapshot.id,
            value: snapshot.value,
            coordinate: snapshot.coordinate,
            appearsWithAnimation: appearsWithAnimation
        )
    }
}

private struct FieldCellSnapshot: Identifiable, Equatable {
    let id: UUID
    let value: Int
    let coordinate: Coordinate
    
    init(cell: FieldCell) {
        id = cell.id
        value = cell.value
        coordinate = cell.coordinate
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        FieldView(game: GameModel())
    }
}
