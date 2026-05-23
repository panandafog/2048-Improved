//
//  GameView.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct GameView: View {
    @StateObject var game = GameModel()
    @Binding var showHowToPlay: Bool
    
    private static let verticalSpacing: CGFloat = 10
    private static let scoreStackHeight: CGFloat = 60
    private static let bottomStackHeight: CGFloat = 60
    private static let maxFieldSize: CGFloat = 500
    private static let minFieldSize: CGFloat = 300
    
    private static let notFieldHeight: CGFloat = scoreStackHeight + verticalSpacing * 2 + bottomStackHeight
#if os(macOS)
    private static let trackpadSwipeMinimumDistance: CGFloat = 30
    private static let trackpadSwipeResetInterval: TimeInterval = 0.25
#endif
    
    @State private var width = CGFloat.zero
#if os(macOS)
    @State private var keyDownEventMonitor: Any?
    @State private var gestureEventMonitor: Any?
    @State private var trackpadSwipeDelta = CGSize.zero
    @State private var trackpadSwipeHandled = false
    @State private var lastTrackpadScrollEventTime: TimeInterval = 0
#endif
    
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
            addInputEventMonitors()
#endif
        }
        .onDisappear {
#if os(macOS)
            removeInputEventMonitors()
#endif
        }
    }
}

#if os(macOS)
private extension GameView {
    func addInputEventMonitors() {
        if keyDownEventMonitor == nil {
            keyDownEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if let direction = MoveDirection(keyCode: event.keyCode) {
                    game.move(direction)
                    return nil
                }
                return event
            }
        }
        
        if gestureEventMonitor == nil {
            gestureEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .swipe]) { event in
                handleGestureEvent(event)
            }
        }
    }
    
    func removeInputEventMonitors() {
        if let keyDownEventMonitor {
            NSEvent.removeMonitor(keyDownEventMonitor)
            self.keyDownEventMonitor = nil
        }
        
        if let gestureEventMonitor {
            NSEvent.removeMonitor(gestureEventMonitor)
            self.gestureEventMonitor = nil
        }
    }
    
    func handleGestureEvent(_ event: NSEvent) -> NSEvent? {
        switch event.type {
        case .swipe:
            guard let direction = MoveDirection(swipeDeltaX: event.deltaX, deltaY: event.deltaY) else {
                return event
            }
            game.move(direction)
            return nil
        case .scrollWheel:
            guard event.hasPreciseScrollingDeltas else {
                return event
            }
            
            let hasGesturePhase = !event.phase.isEmpty
            
            if hasGesturePhase && (event.phase.contains(.began) || event.phase.contains(.mayBegin)) {
                resetTrackpadSwipe()
            }
            
            if hasGesturePhase && (event.phase.contains(.ended) || event.phase.contains(.cancelled)) {
                resetTrackpadSwipe()
                return nil
            }
            
            if !hasGesturePhase && event.timestamp - lastTrackpadScrollEventTime > Self.trackpadSwipeResetInterval {
                resetTrackpadSwipe()
            }
            lastTrackpadScrollEventTime = event.timestamp
            
            guard event.momentumPhase.isEmpty else {
                return nil
            }
            
            if trackpadSwipeHandled {
                return nil
            }
            
            let directionMultiplier: CGFloat = event.isDirectionInvertedFromDevice ? -1 : 1
            trackpadSwipeDelta.width += event.scrollingDeltaX * directionMultiplier
            trackpadSwipeDelta.height += event.scrollingDeltaY * directionMultiplier
            
            guard let direction = MoveDirection(
                trackpadSwipeDelta: trackpadSwipeDelta,
                minimumDistance: Self.trackpadSwipeMinimumDistance
            ) else {
                return event
            }
            
            game.move(direction)
            trackpadSwipeHandled = true
            return nil
        default:
            return event
        }
    }
    
    func resetTrackpadSwipe() {
        trackpadSwipeDelta = .zero
        trackpadSwipeHandled = false
    }
}
#endif

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showHowToPlay: .init(get: { true }, set: { _ in }))
    }
}
