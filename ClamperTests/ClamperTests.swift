//
//  ClamperTests.swift
//  ClamperTests
//
//  Created by Mert Can Demir on 21.02.2026.
//

import Testing
@testable import Clamper

@MainActor
struct ClamperTests {

    @Test("A -> B -> A follows defaults contract")
    func defaultToLinkedToDefaultTransition() {
        let state = SpacingState(currentSpacing: nil, padding: nil)

        #expect(!state.isSpacingSet)
        #expect(state.isPaddingLinked)
        #expect(!state.hasPendingChanges)

        state.setSpacingEnabled(true)

        #expect(state.isSpacingSet)
        #expect(state.isPaddingLinked)
        #expect(state.spacing == Double(SpacingService.defaultSpacing))
        #expect(state.hasPendingChanges)

        state.setSpacingEnabled(false)

        #expect(!state.isSpacingSet)
        #expect(state.isPaddingLinked)
        #expect(state.spacing == 25)
        #expect(state.displayPadding == 25)
        #expect(!state.hasPendingChanges)
    }

    @Test("Linked auto-padding boundaries seed correctly when entering manual mode")
    func autoPaddingBoundarySeeding() {
        let state = SpacingState(currentSpacing: SpacingService.defaultSpacing, padding: nil)

        let samples: [(spacing: Int, expectedPadding: Int)] = [
            (1, 1),
            (6, 1),
            (7, 1),
            (50, 44),
        ]

        for sample in samples {
            state.spacing = Double(sample.spacing)
            state.setPaddingLinked(false)

            #expect(!state.isPaddingLinked)
            #expect(state.isPaddingSet)
            #expect(Int(state.padding) == sample.expectedPadding)

            state.setPaddingLinked(true)
            #expect(state.isPaddingLinked)
            #expect(!state.isPaddingSet)
        }
    }

    @Test("Mode-only B <-> C changes are pending")
    func modeSwitchWithoutKeyValueChangeIsPending() {
        let state = SpacingState(currentSpacing: SpacingService.defaultSpacing, padding: nil)

        #expect(!state.hasPendingChanges)
        #expect(state.isPaddingLinked)

        state.setPaddingLinked(false)
        #expect(!state.isPaddingLinked)
        #expect(state.padding == Double(SpacingService.defaultPadding))
        #expect(state.hasPendingChanges)

        state.setPaddingLinked(true)
        #expect(state.isPaddingLinked)
        #expect(!state.hasPendingChanges)
    }

    @Test("Manual padding cannot be enabled when spacing is disabled")
    func cannotEnterManualModeFromDefaultState() {
        let state = SpacingState(currentSpacing: nil, padding: nil)

        state.setPaddingLinked(false)

        #expect(!state.isSpacingSet)
        #expect(state.isPaddingLinked)
        #expect(!state.isPaddingSet)
        #expect(!state.hasPendingChanges)
    }

    @Test("Startup infers A/B/C from persisted values")
    func startupInference() {
        let defaultsState = SpacingState(currentSpacing: nil, padding: nil)
        #expect(!defaultsState.isSpacingSet)
        #expect(defaultsState.isPaddingLinked)
        #expect(!defaultsState.hasPendingChanges)

        let linkedStateFromSpacingOnly = SpacingState(currentSpacing: 7, padding: nil)
        #expect(linkedStateFromSpacingOnly.isSpacingSet)
        #expect(linkedStateFromSpacingOnly.isPaddingLinked)
        #expect(linkedStateFromSpacingOnly.displayPadding == 25)
        #expect(!linkedStateFromSpacingOnly.hasPendingChanges)

        let linkedStateFromMatchingPadding = SpacingState(currentSpacing: 7, padding: 1)
        #expect(linkedStateFromMatchingPadding.isSpacingSet)
        #expect(linkedStateFromMatchingPadding.isPaddingLinked)
        #expect(!linkedStateFromMatchingPadding.hasPendingChanges)

        let manualState = SpacingState(currentSpacing: 7, padding: 5)
        #expect(manualState.isSpacingSet)
        #expect(!manualState.isPaddingLinked)
        #expect(manualState.padding == 5)
        #expect(!manualState.hasPendingChanges)
    }
}
