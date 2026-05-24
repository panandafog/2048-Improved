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
    
#if os(tvOS)
    var title: String? = nil
#endif
    
    // MARK: - Layout
    
    private let textPadding: CGFloat = 3
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
#if os(tvOS)
        title ?? kind.title
#else
        kind.title
#endif
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
