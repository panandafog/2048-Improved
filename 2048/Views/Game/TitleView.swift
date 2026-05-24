//
//  TitleView.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        Text("2048")
            .font(.largeTitle)
            .foregroundColor(.labelDark)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
