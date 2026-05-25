//
//  CellView.swift
//  2048
//
//  Created by Andrey on 06.05.2023.
//

import SwiftUI

struct FieldCellView: View {
    // MARK: - Input
    
    let value: Int?
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                cellBackground
                valueLabel(in: geometry.size)
            }
        }
    }
}

private extension FieldCellView {
    // MARK: - Rendering
    
    var cellBackground: some View {
        Rectangle()
            .cornerRadius(.CornerRadius.fieldCell)
            .foregroundColor(Color.cellForeground(value))
            .animation(FieldCellAnimation.valueChange, value: value)
    }
    
    @ViewBuilder
    func valueLabel(in size: CGSize) -> some View {
        if let value {
            Text(String(value))
                // Recreate the label when the number changes so merge transitions run.
                .id(value)
                .foregroundColor(Color.cellLabel(value))
                .font(.system(size: fontSize(for: size)))
                .transition(FieldCellAnimation.valueTransition)
                .animation(FieldCellAnimation.valueChange, value: value)
        }
    }
    
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.height, size.width) * FieldCellLayout.fontSizeFactor
    }
}

// MARK: - Layout

private enum FieldCellLayout {
    static let fontSizeFactor: CGFloat = 0.4
}

// MARK: - Animation Parameters

private enum FieldCellAnimation {
    static let valueChangeDuration: TimeInterval = 0.14
    static let labelTransitionScale: CGFloat = 0.7
    
    static let valueChange = Animation.easeOut(duration: valueChangeDuration)
    static let valueTransition = AnyTransition
        .opacity
        .combined(with: .scale(scale: labelTransitionScale))
}

// MARK: - Preview

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        FieldCellView(value: 2)
    }
}
