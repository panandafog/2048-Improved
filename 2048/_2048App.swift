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
#if os(tvOS)
            TVContentView()
                .onAppear(perform: GameCenterService.shared.authenticate)
#else
            ContentView()
                .onAppear(perform: GameCenterService.shared.authenticate)
#endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
