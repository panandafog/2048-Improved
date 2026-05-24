//
//  ScoreView.swift
//  2048
//
//  Created by Andrey on 08.05.2023.
//

import SwiftUI

struct ScoreView: View {
    // MARK: - Input
    
    let kind: ScoreViewKind
    var value: Int
    var title: String? = nil
    
    // MARK: - Layout
    
#if os(tvOS)
    private let textPadding: CGFloat = 6
#else
    private let textPadding: CGFloat = 3
#endif
    private let minWidth: CGFloat = 70
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text(scoreTitle)
                .font(.headline)
#if os(tvOS)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
#endif
                .textCase(.uppercase)
                .foregroundColor(.labelLight2)
                .padding([.top, .horizontal], textPadding)
            Text(String(value))
                .font(.title2)
#if os(tvOS)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
#endif
                .foregroundColor(.labelLight)
                .padding([.bottom, .horizontal], textPadding)
        }
        .frame(minWidth: minWidth)
        .padding(textPadding)
        .background(Color.fieldForeground)
        .cornerRadius(.CornerRadius.score)
    }
}

private extension ScoreView {
    var scoreTitle: String {
        title ?? kind.title
    }
}

// MARK: - Title Mapping

extension ScoreViewKind {
    var title: String {
        switch self {
        case .current:
            return "Score".localized
        case .best:
            return "Best".localized
        }
    }
}

// MARK: - Preview

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(kind: .current, value: 2)
    }
}
