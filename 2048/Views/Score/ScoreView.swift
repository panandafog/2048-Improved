//
//  ScoreView.swift
//  2048
//
//  Created by Andrey on 08.05.2023.
//

import SwiftUI

struct ScoreView: View {
    let kind: ScoreViewKind
    var value: Int
    
    private let textPadding: CGFloat = 3
    private let minWidth: CGFloat = 70
    
    var body: some View {
        VStack {
            Text(kind.title)
                .font(.headline)
                .textCase(.uppercase)
                .foregroundColor(.labelLight2)
                .padding([.top, .horizontal], textPadding)
            Text(String(value))
                .font(.title2)
                .foregroundColor(.labelLight)
                .padding([.bottom, .horizontal], textPadding)
        }
        .frame(minWidth: minWidth)
        .padding(textPadding)
        .background(Color.fieldForeground)
        .cornerRadius(.CornerRadius.score)
    }
}

extension ScoreViewKind {
    var title: String {
        switch self {
        case .current:
            return "Score"
        case .best:
            return "Best"
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(kind: .current, value: 2)
    }
}
