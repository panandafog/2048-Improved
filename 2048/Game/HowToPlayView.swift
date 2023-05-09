//
//  HowToPlayView.swift
//  2048
//
//  Created by Andrey on 09.05.2023.
//

import SwiftUI

struct HowToPlayView: View {
    
    private let text = """
Use your arrow keys to move the tiles.
Tiles with the same number merge into one when they touch.
Add them up to reach 2048!
"""
    
    var body: some View {
        Text(text)
    }
}

struct HowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayView()
    }
}
