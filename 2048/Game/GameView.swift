//
//  GameView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game = GameModel()
    
    private static let verticalSpacing: CGFloat = 2
    private static let scoreStackHeight: CGFloat = 70
    private static let bottomStackHeight: CGFloat = 70
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
                    Spacer()
                    Button("New Game", action: { game.requestNewGame() })
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
            "Start new game?",
            isPresented: $game.newGameRequested
        ) {
            Button("Start", role: .destructive) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
            Button("Cancel", role: .cancel) {
                game.cancelNewGame()
            }
        }
        .alert(
            "Victory!!! 🎉🎉🎉",
            isPresented: $game.victory
        ) {
            Button("Start new game", role: .cancel) {
                do {
                    try game.startNewGame()
                } catch {
                    print("Can't start the game")
                }
            }
        }
        .alert(
            "You lose 🥲",
            isPresented: $game.lose
        ) {
            Button("Start new game", role: .cancel) {
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
                if let moveDirection = MoveDirection(keyCode: event.keyCode) {
                    game.move(moveDirection)
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
        GameView()
    }
}

struct ViewWidthKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
