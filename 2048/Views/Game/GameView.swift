//
//  GameView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct GameView: View {
    @StateObject var game = GameModel()
    @Binding var showHowToPlay: Bool
    
    private static let verticalSpacing: CGFloat = 10
    private static let scoreStackHeight: CGFloat = 60
    private static let bottomStackHeight: CGFloat = 60
    private static let maxFieldSize: CGFloat = 500
    private static let minFieldSize: CGFloat = 300
    
    private static let notFieldHeight: CGFloat = scoreStackHeight + verticalSpacing * 2 + bottomStackHeight
    
    @State private var width = CGFloat.zero
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Self.verticalSpacing) {
                let fieldSize = min(
                    geometry.size.width,
                    geometry.size.height - Self.notFieldHeight
                )
                
                HStack {
                    TitleView()
                    Spacer()
                    ScoreView(kind: .current, value: game.score)
                    ScoreView(kind: .best, value: game.bestScore)
                }
                .frame(
                    width: fieldSize,
                    height: Self.scoreStackHeight
                )
                
                FieldView(game: game)
                    .frame(width: fieldSize, height: fieldSize)
                
                HStack {
                    Button("Button.HowToPlay".localized, action: {
                        withAnimation {
                            showHowToPlay.toggle()
                        }
                    })
                    .buttonStyle(HowToPlayButton())
                    Button("Button.NewGame".localized, action: { game.requestNewGame() })
                        .buttonStyle(GameButton())
                }
                .frame(
                    width: fieldSize,
                    height: Self.bottomStackHeight
                )
            }
            .position(
                x: geometry.frame(in: .local).midX,
                y: geometry.frame(in: .local).midY
            )
        }
        .alert(
            "Alert.NewGame.Title".localized,
            isPresented: $game.newGameRequested
        ) {
            Button("Start".localized, role: .destructive) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
            Button("Cancel".localized, role: .cancel) {
                game.cancelNewGame()
            }
        }
        .alert(
            "Alert.Victory.Title".localized,
            isPresented: $game.victory
        ) {
            Button("Alert.Victory.Button.NewGame".localized, role: .cancel) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
        }
        .alert(
            "Alert.Lose.Title".localized,
            isPresented: $game.lose
        ) {
            Button("Alert.Lose.Button.NewGame".localized, role: .cancel) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
        }
        .frame(
            minWidth: Self.minFieldSize,
            maxWidth: Self.maxFieldSize,
            minHeight: Self.minFieldSize + Self.notFieldHeight,
            maxHeight: Self.maxFieldSize + Self.notFieldHeight
        )
        .background(Color.gameForeground)
        .onAppear {
            do {
                try game.start()
            } catch {
                fatalError("Can't start the game")
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded { value in
                let vector = CGVector(
                    dx: value.translation.width,
                    dy: value.translation.height
                )
                
                let angle = atan2(vector.dx, vector.dy) - atan2(1, 0)
                var degrees = angle * CGFloat(180.0 / Double.pi)
                if degrees < 0 { degrees += 360.0 }
                
                if let direction = MoveDirection(degrees: degrees) {
                    game.move(direction)
                }
            }
        )
        .onAppear {
#if os(macOS)
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
                if let direction = MoveDirection(keyCode: event.keyCode) {
                    game.move(direction)
                    return nil
                }
                return event
            }
            
            //            NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
            //                print("dx = \(event.deltaX)  dy = \(event.deltaY)")
            //                return event
            //            }
#endif
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showHowToPlay: .init(get: { true }, set: { _ in }))
    }
}
