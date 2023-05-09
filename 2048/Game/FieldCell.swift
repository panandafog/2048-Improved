//
//  FieldCell.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import Foundation

class FieldCell: Identifiable, Hashable, ObservableObject {
    let id = UUID()
    
    @Published var value: Int
    var coordinate: Coordinate
    
    init(value: Int, coordinate: Coordinate) {
        self.value = value
        self.coordinate = coordinate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FieldCell: Equatable {
    static func == (lhs: FieldCell, rhs: FieldCell) -> Bool {
        lhs.id == rhs.id
    }
}
