//
//  FieldView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct FieldView: View {
    static let indent: CGFloat = 10
    
    @ObservedObject var game: GameModel
    @State var cells: [FieldCell] = []
    
    var body: some View {
        GeometryReader { geometry in
            let allIndents = FieldView.indent * CGFloat(game.field.fieldSize + 1)
            let cellWidth = (geometry.size.width - allIndents) / CGFloat(game.field.fieldSize)
            let cellHeight = (geometry.size.height - allIndents) / CGFloat(game.field.fieldSize)
            
            ForEach(0 ..< game.field.fieldSize) { rowInd in
                ForEach(0 ..< game.field.fieldSize) { colInd in
                    CellView(value: nil)
                        .position(
                            x: Self.indent * CGFloat(colInd + 1) + cellWidth * (CGFloat(colInd) + 0.5),
                            y: Self.indent * CGFloat(rowInd + 1) + cellHeight * (CGFloat(rowInd) + 0.5)
                        )
                        .frame(width: cellWidth, height: cellHeight)
                }
            }
            
            ForEach(cells, id: \.self) { cell in
                let rowInd = cell.coordinate.row
                let colInd = cell.coordinate.col
                CellView(value: cell.value)
                    .position(
                        x: Self.indent * CGFloat(colInd + 1) + cellWidth * (CGFloat(colInd) + 0.5),
                        y: Self.indent * CGFloat(rowInd + 1) + cellHeight * (CGFloat(rowInd) + 0.5)
                    )
                    .frame(width: cellWidth, height: cellHeight)
            }
            .onReceive(game.field.objectWillChange) { newCells in
                withAnimation {
                    cells = Array(game.field.cells)
                }
            }
        }
        .background(Color.fieldForeground)
        .cornerRadius(10)
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        FieldView(game: GameModel())
    }
}
