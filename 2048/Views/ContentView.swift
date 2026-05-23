//
//  ContentView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - State
    
    @State var showHowToPlay = false
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                GameView(showHowToPlay: $showHowToPlay)
                if showHowToPlay {
                    Divider()
                    HowToPlayView()
                }
                Spacer()
            }
            Spacer()
        }
        .background(Color.gameForeground)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
