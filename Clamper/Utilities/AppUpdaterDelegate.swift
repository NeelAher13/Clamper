//
//  AppUpdaterDelegate.swift
//  Clamper
//

import Sparkle

@MainActor
final class AppUpdaterDelegate: NSObject, SPUStandardUserDriverDelegate {
    private var isInitialLaunch = true

    override init() {
        super.init()
        Task {
            try? await Task.sleep(for: .seconds(30))
            isInitialLaunch = false
        }
    }

    var supportsGentleScheduledUpdateReminders: Bool {
        true
    }

    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        let shouldShowModal = isInitialLaunch
        if isInitialLaunch {
            isInitialLaunch = false
        }
        return shouldShowModal
    }
}
