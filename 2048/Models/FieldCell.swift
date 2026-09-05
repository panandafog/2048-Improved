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
