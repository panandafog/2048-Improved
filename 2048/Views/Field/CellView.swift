//
//  CellView.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import SwiftUI

struct FieldCellView: View {
    var value: Int?
    
    private static let fontMultiplier = 0.4
    private static let valueAnimation = Animation.easeOut(duration: 0.14)
    private static let valueTransition = AnyTransition
        .opacity
        .combined(with: .scale(scale: 0.7))
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .cornerRadius(.CornerRadius.fieldCell)
                    .foregroundColor(Color.cellForeground(value))
                    .animation(Self.valueAnimation, value: value)
                if let value = value {
                    Text(String(value))
                        .id(value)
                        .foregroundColor(Color.cellLabel(value))
                        .animation(Self.valueAnimation, value: value)
                        .font(
                            .system(
                                size:
                                    min(
                                        geometry.size.height,
                                        geometry.size.width
                                    ) * Self.fontMultiplier
                            )
                        )
                        .transition(Self.valueTransition)
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
