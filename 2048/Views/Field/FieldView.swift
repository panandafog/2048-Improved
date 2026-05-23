//
//  FieldView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct FieldView: View {
    // MARK: - State
    
    @ObservedObject var game: GameModel
    
    // FieldCell is mutable, so the view keeps value snapshots for stable animations.
    @State private var cells: [RenderedFieldCell] = []
    @State private var pendingValueUpdates: [UUID: DispatchWorkItem] = [:]
    @State private var pendingCellInsertions: [UUID: DispatchWorkItem] = [:]
    @State private var pendingFadeIns: [UUID: DispatchWorkItem] = [:]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let metrics = FieldLayoutMetrics(
                containerSize: geometry.size,
                fieldSize: game.field.fieldSize
            )
            
            backgroundCells(metrics: metrics)
            activeCells(metrics: metrics)
        }
        .background(Color.fieldForeground)
        .cornerRadius(FieldLayout.cornerRadius)
    }
}

private extension FieldView {
    // MARK: - Rendering
    
    func backgroundCells(metrics: FieldLayoutMetrics) -> some View {
        ForEach(metrics.indices, id: \.self) { row in
            ForEach(metrics.indices, id: \.self) { col in
                let coordinate = Coordinate(row: row, col: col)
                
                FieldCellView(value: nil)
                    .frame(width: metrics.cellSize.width, height: metrics.cellSize.height)
                    .position(metrics.center(for: coordinate))
            }
        }
    }
    
    func activeCells(metrics: FieldLayoutMetrics) -> some View {
        ForEach(cells) { cell in
            FieldCellView(value: cell.value)
                .compositingGroup()
                .frame(width: metrics.cellSize.width, height: metrics.cellSize.height)
                .position(metrics.center(for: cell.coordinate))
                .opacity(cell.isFadingIn ? FieldAnimation.hiddenOpacity : FieldAnimation.visibleOpacity)
                .transition(.identity)
        }
        .onReceive(game.field.objectWillChange) { _ in
            updateCells(with: game.field.cells.map { FieldCellSnapshot(cell: $0) })
        }
    }
}

private extension FieldView {
    // MARK: - Render Updates
    
    func updateCells(with snapshots: [FieldCellSnapshot]) {
        cancelPendingAnimationWork()
        
        let update = makeRenderUpdate(from: snapshots)
        applyVisibleCells(update.visibleCells, hasMovingCells: update.hasMovingCells)
        
        if update.hasMovingCells {
            scheduleCellInsertions(update.deferredCells)
        } else {
            scheduleFadeIn(for: update.visibleCells.filter(\.isFadingIn).map(\.id))
        }
        
        scheduleValueUpdates(update.valueUpdates)
    }
    
    func makeRenderUpdate(from snapshots: [FieldCellSnapshot]) -> FieldRenderUpdate {
        var valueUpdates: [DelayedValueUpdate] = []
        var deferredCells: [RenderedFieldCell] = []
        
        let currentCells = Dictionary(uniqueKeysWithValues: cells.map { ($0.id, $0) })
        let hasMovingCells = snapshots.contains { snapshot in
            guard let currentCell = currentCells[snapshot.id] else {
                return false
            }
            
            return currentCell.coordinate != snapshot.coordinate
        }
        
        let visibleCells = snapshots.compactMap { snapshot -> RenderedFieldCell? in
            guard let currentCell = currentCells[snapshot.id] else {
                let newCell = RenderedFieldCell(snapshot: snapshot, isFadingIn: true)
                
                if hasMovingCells {
                    deferredCells.append(newCell)
                    return nil
                }
                
                return newCell
            }
            
            guard isMergedMovingCell(currentCell, snapshot: snapshot) else {
                return RenderedFieldCell(snapshot: snapshot)
            }
            
            valueUpdates.append(DelayedValueUpdate(id: snapshot.id, value: snapshot.value))
            
            // During a merge, keep the old value until movement finishes.
            return RenderedFieldCell(
                id: snapshot.id,
                value: currentCell.value,
                coordinate: snapshot.coordinate
            )
        }
        
        return FieldRenderUpdate(
            visibleCells: visibleCells,
            deferredCells: deferredCells,
            valueUpdates: valueUpdates,
            hasMovingCells: hasMovingCells
        )
    }
    
    func isMergedMovingCell(_ currentCell: RenderedFieldCell, snapshot: FieldCellSnapshot) -> Bool {
        currentCell.value != snapshot.value && currentCell.coordinate != snapshot.coordinate
    }
}

private extension FieldView {
    // MARK: - Animation Scheduling
    
    func scheduleCellInsertions(_ deferredCells: [RenderedFieldCell]) {
        guard !deferredCells.isEmpty else {
            return
        }
        
        let ids = deferredCells.map(\.id)
        let workItem = DispatchWorkItem {
            ids.forEach { pendingCellInsertions[$0] = nil }
            insertDeferredCells(deferredCells)
        }
        
        ids.forEach { pendingCellInsertions[$0] = workItem }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + FieldAnimation.moveDuration,
            execute: workItem
        )
    }
    
    func scheduleValueUpdates(_ updates: [DelayedValueUpdate]) {
        updates.forEach { update in
            let workItem = DispatchWorkItem {
                applyDelayedValue(update.value, to: update.id)
            }
            
            pendingValueUpdates[update.id] = workItem
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + FieldAnimation.moveDuration,
                execute: workItem
            )
        }
    }
    
    func scheduleFadeIn(for ids: [UUID]) {
        let ids = Array(Set(ids))
        guard !ids.isEmpty else {
            return
        }
        
        ids.forEach { pendingFadeIns[$0]?.cancel() }
        
        let workItem = DispatchWorkItem {
            ids.forEach { pendingFadeIns[$0] = nil }
            
            withAnimation(FieldAnimation.appearance) {
                finishFadeIn(for: ids)
            }
        }
        
        ids.forEach { pendingFadeIns[$0] = workItem }
        DispatchQueue.main.async(execute: workItem)
    }
}

private extension FieldView {
    // MARK: - State Mutations
    
    func applyVisibleCells(_ visibleCells: [RenderedFieldCell], hasMovingCells: Bool) {
        if hasMovingCells {
            withAnimation(FieldAnimation.move) {
                cells = visibleCells
            }
        } else {
            replaceCellsWithoutAnimation(visibleCells)
        }
    }
    
    func insertDeferredCells(_ deferredCells: [RenderedFieldCell]) {
        let existingIDs = Set(cells.map(\.id))
        let newCells = deferredCells.filter { !existingIDs.contains($0.id) }
        
        guard !newCells.isEmpty else {
            return
        }
        
        replaceCellsWithoutAnimation(cells + newCells)
        scheduleFadeIn(for: newCells.map(\.id))
    }
    
    func applyDelayedValue(_ value: Int, to id: UUID) {
        pendingValueUpdates[id] = nil
        
        guard let index = cells.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var updatedCells = cells
        updatedCells[index].value = value
        
        withAnimation(FieldAnimation.merge) {
            cells = updatedCells
        }
    }
    
    func finishFadeIn(for ids: [UUID]) {
        var updatedCells = cells
        var didUpdate = false
        
        for id in ids {
            guard let index = updatedCells.firstIndex(where: { $0.id == id }) else {
                continue
            }
            
            updatedCells[index].isFadingIn = false
            didUpdate = true
        }
        
        guard didUpdate else {
            return
        }
        
        cells = updatedCells
    }
    
    func replaceCellsWithoutAnimation(_ newCells: [RenderedFieldCell]) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            cells = newCells
        }
    }
}

private extension FieldView {
    // MARK: - Cancellation
    
    func cancelPendingAnimationWork() {
        cancelPendingValueUpdates()
        cancelPendingCellInsertions()
        cancelPendingFadeIns()
    }
    
    func cancelPendingValueUpdates() {
        pendingValueUpdates.values.forEach { $0.cancel() }
        pendingValueUpdates = [:]
    }
    
    func cancelPendingCellInsertions() {
        pendingCellInsertions.values.forEach { $0.cancel() }
        pendingCellInsertions = [:]
    }
    
    func cancelPendingFadeIns() {
        pendingFadeIns.values.forEach { $0.cancel() }
        pendingFadeIns = [:]
    }
}

// MARK: - Preview

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        FieldView(game: GameModel())
    }
}
