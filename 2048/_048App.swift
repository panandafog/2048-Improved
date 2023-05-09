//
//  _048App.swift
//  2048
//
//  Created by Andrey on 05.05.2023.
//

import SwiftUI

@main
struct _048App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
//        .windowResizabilityContentSize()
    }
}

extension Scene {
//    func windowResizabilityContentSize() -> some Scene {
//        if #available(macOS 13.0, *) {
//            return windowResizability(.contentSize)
//        } else {
//            return self
//        }
//    }
}
