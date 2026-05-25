//
//  FieldLayout.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import SwiftUI

// MARK: - Constants

enum FieldLayout {
    static let cellSpacing: CGFloat = 10
    static let cornerRadius = CGFloat.CornerRadius.field
    static let surroundingGapCountOffset = 1
    static let leadingGapCountOffset = 1
    static let cellCenterOffset: CGFloat = 0.5
}

// MARK: - Metrics

struct FieldLayoutMetrics {
    // MARK: - Properties
    
    let fieldSize: Int
    let cellSize: CGSize
    
    var indices: Range<Int> {
        0 ..< fieldSize
    }
    
    // MARK: - Lifecycle
    
    init(containerSize: CGSize, fieldSize: Int) {
        self.fieldSize = fieldSize
        
        // The grid has a gap before the first cell, after the last cell, and between cells.
        let gapCount = fieldSize + FieldLayout.surroundingGapCountOffset
        let totalGapSize = FieldLayout.cellSpacing * CGFloat(gapCount)
        let cellWidth = (containerSize.width - totalGapSize) / CGFloat(fieldSize)
        let cellHeight = (containerSize.height - totalGapSize) / CGFloat(fieldSize)
        
        cellSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - Positioning
    
    func center(for coordinate: Coordinate) -> CGPoint {
        CGPoint(
            x: centerCoordinate(for: coordinate.col, cellLength: cellSize.width),
            y: centerCoordinate(for: coordinate.row, cellLength: cellSize.height)
        )
    }
    
    private func centerCoordinate(for index: Int, cellLength: CGFloat) -> CGFloat {
        let leadingGaps = CGFloat(index + FieldLayout.leadingGapCountOffset)
        let leadingCells = CGFloat(index) + FieldLayout.cellCenterOffset
        
        return FieldLayout.cellSpacing * leadingGaps + cellLength * leadingCells
    }
}
