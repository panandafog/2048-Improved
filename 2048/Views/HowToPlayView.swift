//
//  HowToPlayView.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct HowToPlayView: View {
    // MARK: - Content
    
#if os(macOS)
    private let text = "HowToPlay.macOS".localized
#else
    private let text = "HowToPlay.other".localized
#endif
    
    // MARK: - Body
    
    var body: some View {
        Text(text)
            .font(.callout)
            .foregroundColor(.labelDark)
    }
}

// MARK: - Preview

struct HowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayView()
    }
}
