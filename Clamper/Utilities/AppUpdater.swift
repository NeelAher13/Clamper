//
//  AppUpdater.swift
//  Clamper
//

import Combine
import Foundation
import Sparkle

@MainActor
@Observable
final class AppUpdater {
    private let updaterController: SPUStandardUpdaterController
    private let delegate = AppUpdaterDelegate()
    private var cancellables = Set<AnyCancellable>()

    private(set) var canCheckForUpdates = false

    var automaticallyChecksForUpdates: Bool {
        get { updaterController.updater.automaticallyChecksForUpdates }
        set { updaterController.updater.automaticallyChecksForUpdates = newValue }
    }

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: delegate
        )

        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.canCheckForUpdates = value
            }
            .store(in: &cancellables)
    }

    func checkForUpdates() {
        updaterController.updater.checkForUpdates()
    }
}
