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
    let kind: FieldCellKind

    init(value: Int?, kind: FieldCellKind = .normal) {
        self.value = value
        self.kind = kind
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                cellBackground
                valueLabel(in: geometry.size)
                effectBadge(in: geometry.size)
            }
        }
    }
}

private extension FieldCellView {
    // MARK: - Rendering
    
    var cellBackground: some View {
        Rectangle()
            .cornerRadius(.CornerRadius.fieldCell)
            .foregroundColor(backgroundColor)
            .animation(FieldCellAnimation.valueChange, value: kind)
    }

    var backgroundColor: Color {
        switch kind {
        case .normal:
            return Color.cellForeground(value)
        case .wild:
            return .anomalyWild
        case .frozen:
            return .anomalyFrozen
        case .bomb:
            return .anomalyBomb
        case .power:
            return .anomalyPower
        case .stone:
            return .anomalyStone
        }
    }
    
    @ViewBuilder
    func valueLabel(in size: CGSize) -> some View {
        if kind == .wild {
            Image(systemName: "sparkles")
                .font(.system(size: symbolSize(for: size), weight: .bold))
                .foregroundColor(.labelLight)
        } else if let value {
            Text(String(value))
                // Recreate the label when the number changes so merge transitions run.
                .id(value)
                .foregroundColor(labelColor(for: value))
                .font(.system(size: fontSize(for: size)))
                .transition(FieldCellAnimation.valueTransition)
                .animation(FieldCellAnimation.valueChange, value: value)
        }
    }
    
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.height, size.width) * FieldCellLayout.fontSizeFactor
    }

    func symbolSize(for size: CGSize) -> CGFloat {
        min(size.height, size.width) * FieldCellLayout.symbolSizeFactor
    }

    func labelColor(for value: Int) -> Color {
        switch kind {
        case .frozen, .power:
            return .labelDark
        case .bomb, .stone:
            return .labelLight
        default:
            return Color.cellLabel(value)
        }
    }

    @ViewBuilder
    func effectBadge(in size: CGSize) -> some View {
        VStack {
            HStack {
                Spacer()

                switch kind {
                case .frozen(let remainingMoves):
                    Label(String(remainingMoves), systemImage: "snowflake")
                case .bomb:
                    Image(systemName: "burst.fill")
                case .power:
                    Image(systemName: "bolt.fill")
                case .stone(let remainingMoves):
                    Label(String(remainingMoves), systemImage: "lock.fill")
                default:
                    EmptyView()
                }
            }

            Spacer()
        }
        .font(.system(size: min(size.width, size.height) * FieldCellLayout.badgeSizeFactor, weight: .bold))
        .foregroundColor(effectBadgeColor)
        .padding(min(size.width, size.height) * FieldCellLayout.badgePaddingFactor)
    }

    var effectBadgeColor: Color {
        switch kind {
        case .frozen, .power:
            return .labelDark
        default:
            return .labelLight
        }
    }
}

// MARK: - Layout

private enum FieldCellLayout {
    static let fontSizeFactor: CGFloat = 0.4
    static let symbolSizeFactor: CGFloat = 0.34
    static let badgeSizeFactor: CGFloat = 0.13
    static let badgePaddingFactor: CGFloat = 0.08
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
