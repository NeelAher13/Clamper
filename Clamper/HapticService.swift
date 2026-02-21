//
//  HapticService.swift
//  Clamper
//
//  Created by Mert Can Demir on 28.02.2026.
//

import AppKit

enum HapticService {
    static func tick() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            .alignment,
            performanceTime: .default
        )
    }
}
