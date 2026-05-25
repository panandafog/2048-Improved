//
//  GameView+Input.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

// MARK: - SwiftUI Gestures

#if !os(tvOS)
extension GameView {
    var moveDragGesture: some Gesture {
        DragGesture(
            minimumDistance: GameGestureParameters.dragMinimumDistance,
            coordinateSpace: GameGestureParameters.dragCoordinateSpace
        )
            .onEnded(handleDragGesture)
    }

    private func handleDragGesture(_ value: DragGesture.Value) {
        let vector = CGVector(
            dx: value.translation.width,
            dy: value.translation.height
        )

        let angle = atan2(vector.dx, vector.dy) - GameGestureParameters.dragAngleOffsetRadians
        var degrees = angle * GameGestureParameters.degreesPerRadian
        if degrees < 0 { degrees += GameGestureParameters.fullCircleDegrees }

        if let direction = MoveDirection(degrees: degrees) {
            game.move(direction)
        }
    }
}
#endif

#if os(tvOS)
extension GameView {
    // MARK: - Remote Input

    func handleMoveCommand(_ direction: MoveCommandDirection) {
        switch direction {
        case .up:
            game.move(.up)
        case .down:
            game.move(.down)
        case .left:
            game.move(.left)
        case .right:
            game.move(.right)
        default:
            break
        }
    }
}
#endif

// MARK: - Keyboard And Trackpad Input

final class GameInputController: ObservableObject {
    private weak var game: GameModel?

#if os(macOS)
    private var gestureEventMonitor: Any?
    private var trackpadSwipeDelta = CGSize.zero
    private var trackpadSwipeHandled = false
    private var lastTrackpadScrollEventTime: TimeInterval = 0
#endif

    // MARK: - Lifecycle

    func start(game: GameModel) {
        self.game = game

#if os(macOS)
        addInputEventMonitors()
#endif
    }

    func stop() {
#if os(macOS)
        removeInputEventMonitors()
#endif
    }

    deinit {
        stop()
    }
}

#if os(macOS)
private extension GameInputController {
    // MARK: - Event Monitors

    func addInputEventMonitors() {
        if gestureEventMonitor == nil {
            gestureEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .swipe]) { [weak self] event in
                self?.handleGestureEvent(event) ?? event
            }
        }
    }

    func removeInputEventMonitors() {
        if let gestureEventMonitor {
            NSEvent.removeMonitor(gestureEventMonitor)
            self.gestureEventMonitor = nil
        }

        resetTrackpadSwipe()
    }

    // MARK: - Event Routing

    func handleGestureEvent(_ event: NSEvent) -> NSEvent? {
        switch event.type {
        case .swipe:
            return handleSwipeEvent(event)
        case .scrollWheel:
            return handleScrollWheelEvent(event)
        default:
            return event
        }
    }

    func handleSwipeEvent(_ event: NSEvent) -> NSEvent? {
        guard let direction = MoveDirection(swipeDeltaX: event.deltaX, deltaY: event.deltaY) else {
            return event
        }

        game?.move(direction)
        return nil
    }

    // MARK: - Trackpad Scroll Gestures

    func handleScrollWheelEvent(_ event: NSEvent) -> NSEvent? {
        // Two-finger trackpad swipes arrive as precise scroll events on macOS.
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

        if !hasGesturePhase && event.timestamp - lastTrackpadScrollEventTime > GameGestureParameters.trackpadSwipeResetInterval {
            resetTrackpadSwipe()
        }
        lastTrackpadScrollEventTime = event.timestamp

        // Ignore the inertial tail so one physical swipe cannot trigger extra moves.
        guard event.momentumPhase.isEmpty else {
            return nil
        }

        if trackpadSwipeHandled {
            return nil
        }

        // Normalize natural scrolling so the tile direction follows finger movement.
        let directionMultiplier: CGFloat = event.isDirectionInvertedFromDevice ? -1 : 1
        trackpadSwipeDelta.width += event.scrollingDeltaX * directionMultiplier
        trackpadSwipeDelta.height += event.scrollingDeltaY * directionMultiplier

        guard let direction = MoveDirection(
            trackpadSwipeDelta: trackpadSwipeDelta,
            minimumDistance: GameGestureParameters.trackpadSwipeMinimumDistance
        ) else {
            return event
        }

        game?.move(direction)
        trackpadSwipeHandled = true
        return nil
    }

    func resetTrackpadSwipe() {
        trackpadSwipeDelta = .zero
        trackpadSwipeHandled = false
    }
}
#endif

#if os(macOS)
struct GameKeyboardInputView: NSViewRepresentable {
    let onMove: (MoveDirection) -> Void

    func makeNSView(context: Context) -> KeyboardInputNSView {
        let view = KeyboardInputNSView()
        view.onMove = onMove
        focus(view)
        return view
    }

    func updateNSView(_ nsView: KeyboardInputNSView, context: Context) {
        nsView.onMove = onMove
        focus(nsView)
    }

    private func focus(_ view: KeyboardInputNSView) {
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
    }
}

final class KeyboardInputNSView: NSView {
    var onMove: ((MoveDirection) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        guard let direction = MoveDirection(keyCode: event.keyCode) else {
            super.keyDown(with: event)
            return
        }

        onMove?(direction)
    }
}
#endif
