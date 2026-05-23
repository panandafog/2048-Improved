//
//  FieldRenderModels.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import Foundation

struct FieldRenderUpdate {
    let visibleCells: [RenderedFieldCell]
    let deferredCells: [RenderedFieldCell]
    let valueUpdates: [DelayedValueUpdate]
    let hasMovingCells: Bool
}

struct DelayedValueUpdate {
    let id: UUID
    let value: Int
}

struct RenderedFieldCell: Identifiable, Equatable {
    let id: UUID
    var value: Int
    var coordinate: Coordinate
    var isFadingIn: Bool
    
    init(
        id: UUID,
        value: Int,
        coordinate: Coordinate,
        isFadingIn: Bool = false
    ) {
        self.id = id
        self.value = value
        self.coordinate = coordinate
        self.isFadingIn = isFadingIn
    }
    
    init(snapshot: FieldCellSnapshot, isFadingIn: Bool = false) {
        self.init(
            id: snapshot.id,
            value: snapshot.value,
            coordinate: snapshot.coordinate,
            isFadingIn: isFadingIn
        )
    }
}

struct FieldCellSnapshot: Identifiable, Equatable {
    let id: UUID
    let value: Int
    let coordinate: Coordinate
    
    init(cell: FieldCell) {
        id = cell.id
        value = cell.value
        coordinate = cell.coordinate
    }
}
