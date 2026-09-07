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
            Group {
#if os(tvOS)
                TVContentView()
#else
                ContentView()
#endif
            }
            .preferredColorScheme(ScreenshotDemoMode.isEnabled ? .light : nil)
            .onAppear {
                guard !ScreenshotDemoMode.isEnabled else {
                    return
                }

                GameCenterService.shared.authenticate()
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
