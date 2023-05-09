//
//  _048App.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

@main
struct _2048App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
