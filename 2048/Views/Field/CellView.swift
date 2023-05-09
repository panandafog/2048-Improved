//
//  CellView.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import SwiftUI

struct FieldCellView: View {
    var value: Int?
    
    private let fontMultiplier = 0.4
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .cornerRadius(.CornerRadius.fieldCell)
                    .foregroundColor(Color.cellForeground(value))
                if let value = value {
                    Text(String(value))
                        .foregroundColor(Color.cellLabel(value))
                        .font(
                            .system(
                                size:
                                    min(
                                        geometry.size.height,
                                        geometry.size.width
                                    ) * fontMultiplier
                            )
                        )
                }
            }
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        FieldCellView(value: 2)
    }
}
