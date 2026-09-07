//
//  TitleView.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct TitleView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .foregroundColor(.labelDark)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: GameMode.anomaly.title)
    }
}
