//
//  SpacingState.swift
//  Clamper
//
//  Created by Mert Can Demir on 22.02.2026.
//

import Foundation

// MARK: - Spacing Snapshot

private enum SpacingMode: Equatable {
    case defaults
    case linked
    case manual
}

private struct SpacingSnapshot: Equatable {
    var mode: SpacingMode
    var spacing: Int?
    var padding: Int?

    static let systemDefaults = SpacingSnapshot(mode: .defaults, spacing: nil, padding: nil)
}

// MARK: - SpacingState

@MainActor
@Observable
final class SpacingState {
    var spacing: Double = Double(SpacingService.defaultSpacing)
    var padding: Double = Double(SpacingService.defaultPadding)
    var isSpacingSet = false
    var isPaddingSet = false
    var isPaddingLinked = true

    var displayPadding: Double {
        isPaddingLinked ? Self.neutralSliderPosition : padding
    }

    var hasPendingChanges: Bool {
        candidate != committed
    }

    convenience init() {
        self.init(
            currentSpacing: SpacingService.readSpacing(),
            padding: SpacingService.readPadding()
        )
    }

    init(currentSpacing: Int?, padding currentPadding: Int?) {
        launchSpacingValue = Double(currentSpacing ?? SpacingService.defaultSpacing)

        if let currentSpacing {
            launchPaddingValue = Double(
                currentPadding ?? Self.linkedPaddingValue(for: currentSpacing)
            )
        } else {
            launchPaddingValue = Double(SpacingService.defaultPadding)
        }

        loadCurrentValues(spacing: currentSpacing, padding: currentPadding)
    }

    // MARK: - Actions

    func apply() {
        applyChanges(logoutAfterApply: false)
    }

    func applyAndLogout() {
        applyChanges(logoutAfterApply: true)
    }

    func reset() {
        enterDefaultState()
    }

    func setSpacingEnabled(_ enabled: Bool) {
        guard enabled != isSpacingSet else { return }
        if enabled {
            spacing = Double(SpacingService.defaultSpacing)
            isSpacingSet = true
            isPaddingSet = false
            isPaddingLinked = true
        } else {
            enterDefaultState()
        }
    }

    func resetSpacingValue() {
        spacing = launchSpacingValue
    }

    func resetPaddingValue() {
        padding = launchPaddingValue
    }

    func setPaddingLinked(_ linked: Bool) {
        guard linked != isPaddingLinked else {
            return
        }

        guard isSpacingSet else {
            return
        }

        if linked {
            isPaddingSet = false
            isPaddingLinked = true
            return
        }

        let linkedValue = Double(Self.linkedPaddingValue(for: Int(spacing)))
        isPaddingLinked = false
        isPaddingSet = true
        padding = linkedValue
    }

    // MARK: - Private

    private static let neutralSliderPosition = Double(
        (SpacingService.validRange.lowerBound + SpacingService.validRange.upperBound) / 2
    )

    private func enterDefaultState() {
        spacing = Self.neutralSliderPosition
        padding = Self.neutralSliderPosition
        isSpacingSet = false
        isPaddingSet = false
        isPaddingLinked = true
    }

    private let launchSpacingValue: Double
    private let launchPaddingValue: Double

    private var committed = SpacingSnapshot.systemDefaults

    private var candidate: SpacingSnapshot {
        SpacingSnapshot(mode: draftMode, spacing: targetSpacingKey, padding: targetPaddingKey)
    }

    private var draftMode: SpacingMode {
        if !isSpacingSet {
            return .defaults
        }

        return isPaddingLinked ? .linked : .manual
    }

    private static let linkedPaddingOffset = SpacingService.defaultSpacing - SpacingService.defaultPadding

    private var targetSpacingKey: Int? {
        isSpacingSet ? Int(spacing) : nil
    }

    private var targetPaddingKey: Int? {
        if isPaddingLinked {
            guard let targetSpacingKey else {
                return nil
            }

            return Self.linkedPaddingValue(for: targetSpacingKey)
        }

        return isPaddingSet ? Int(padding) : nil
    }

    private func loadCurrentValues(spacing currentSpacing: Int?, padding currentPadding: Int?) {
        guard let currentSpacing else {
            enterDefaultState()
            committed = .systemDefaults
            return
        }

        spacing = Double(currentSpacing)
        isSpacingSet = true

        let linkedPadding = Self.linkedPaddingValue(for: currentSpacing)
        if let currentPadding, currentPadding != linkedPadding {
            padding = Double(currentPadding)
            isPaddingSet = true
            isPaddingLinked = false
            committed = SpacingSnapshot(mode: .manual, spacing: currentSpacing, padding: currentPadding)
            return
        }

        padding = Double(linkedPadding)
        isPaddingSet = false
        isPaddingLinked = true
        committed = SpacingSnapshot(mode: .linked, spacing: currentSpacing, padding: linkedPadding)
    }

    private func applyChanges(logoutAfterApply: Bool) {
        let configuration = candidate

        SpacingService.write(spacing: configuration.spacing, padding: configuration.padding)
        committed = configuration

        if logoutAfterApply {
            SpacingService.logout()
        } else {
            SpacingService.restartControlCenter()
        }
    }

    private static func linkedPaddingValue(for spacing: Int) -> Int {
        max(SpacingService.validRange.lowerBound, spacing - linkedPaddingOffset)
    }
}
