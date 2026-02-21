//
//  ClamperApp.swift
//  Clamper
//
//  Created by Mert Can Demir on 21.02.2026.
//

import SwiftUI

@main
struct ClamperApp: App {
    @State private var spacingState = SpacingState()
    @State private var appUpdater = AppUpdater()

    var body: some Scene {
        Window("Clamper", id: "main") {
            ContentView()
                .environment(spacingState)
                .environment(appUpdater)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...", action: appUpdater.checkForUpdates)
                    .disabled(!appUpdater.canCheckForUpdates)
            }
        }
    }
}
