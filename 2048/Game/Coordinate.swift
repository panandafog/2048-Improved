//
//  Coordinate.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

struct Coordinate: Hashable {
    var row: Int
    var col: Int
}

extension Coordinate: Equatable {
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        lhs.row == rhs.row && lhs.col == rhs.col
    }
}
