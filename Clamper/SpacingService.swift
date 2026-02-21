//
//  SpacingService.swift
//  Clamper
//
//  Created by Mert Can Demir on 22.02.2026.
//

import AppKit
import CoreFoundation

enum SpacingService {

    // MARK: - Constants

    static let spacingKey = "NSStatusItemSpacing" as CFString
    static let paddingKey = "NSStatusItemSelectionPadding" as CFString

    static let defaultSpacing = 17
    static let defaultPadding = 11
    static let validRange = 1...50

    // MARK: - Read

    static func readSpacing() -> Int? {
        readKey(spacingKey)
    }

    static func readPadding() -> Int? {
        readKey(paddingKey)
    }

    // MARK: - Write

    static func write(spacing: Int?, padding: Int?) {
        if let spacing {
            writeKey(spacingKey, value: clamped(spacing))
        } else {
            deleteKey(spacingKey)
        }

        if let padding {
            writeKey(paddingKey, value: clamped(padding))
        } else {
            deleteKey(paddingKey)
        }

        synchronize()
    }

    // MARK: - ControlCenter Restart

    static func restartControlCenter() {
        let apps = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.apple.controlcenter"
        )
        if let controlCenter = apps.first {
            controlCenter.terminate()
        }
    }

    // MARK: - Logout

    static func logout() {
        let script = NSAppleScript(
            source: "tell application \"loginwindow\" to «event aevtlogo»"
        )
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
    }

    // MARK: - Private

    private static func clamped(_ value: Int) -> Int {
        min(validRange.upperBound, max(validRange.lowerBound, value))
    }

    private static func readKey(_ key: CFString) -> Int? {
        let value = CFPreferencesCopyValue(
            key,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        guard let intValue = (value as? NSNumber)?.intValue else {
            return nil
        }
        return clamped(intValue)
    }

    private static func writeKey(_ key: CFString, value: Int) {
        CFPreferencesSetValue(
            key,
            value as CFNumber,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
    }

    private static func deleteKey(_ key: CFString) {
        CFPreferencesSetValue(
            key,
            nil,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
    }

    private static func synchronize() {
        CFPreferencesSynchronize(
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
    }
}
