//
//  ContentView.swift
//  Clamper
//
//  Created by Mert Can Demir on 21.02.2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(SpacingState.self) private var state

    var body: some View {
        VStack(spacing: 20) {
            PreviewSection(state: state)
            ControlsSection(state: state)
            ActionSection(state: state)
        }
        .scenePadding()
        .frame(width: 480, alignment: .top)
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Preview Section

private struct PreviewSection: View {
    let state: SpacingState

    private static let icons = [
        "wifi",
        "speaker.wave.2.fill",
        "magnifyingglass",
        "switch.2",
        "music.note",
        "moon.stars",
        "bell",
        "battery.100",
        "bolt.fill",
        "clock",
        "flame",
        "star.fill",
        "heart.fill",
        "eye",
        "paperplane.fill",
        "globe",
        "lock.fill",
        "key.fill",
        "gearshape",
        "person.fill",
        "cloud.fill",
        "sun.max.fill",
        "drop.fill",
        "leaf.fill",
        "camera.fill",
        "mic.fill",
        "phone.fill",
        "envelope.fill",
        "bookmark.fill",
        "tag.fill",
        "map.fill",
        "location.fill",
        "house.fill",
        "car.fill",
        "airplane",
        "bus.fill",
        "tram.fill",
        "ferry.fill",
        "cup.and.saucer.fill",
        "fork.knife"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Preview")
                .font(.headline)
                .foregroundStyle(.secondary)

            GroupBox {
                PreviewIconsRow(
                    icons: Self.icons,
                    spacing: state.isSpacingSet ? state.spacing : Double(SpacingService.defaultSpacing)
                )
            }
        }
    }
}

private struct PreviewIconsRow: View {
    let icons: [String]
    let spacing: Double

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: spacing) {
                ForEach(icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.body)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(.capsule)
        .adaptiveGlassEffect()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Menu bar icon spacing preview")
        .accessibilityValue("\(Int(spacing)) pixel spacing")
    }
}

// MARK: - Controls Section

private struct ControlsSection: View {
    @Bindable var state: SpacingState

    private var paddingBinding: Binding<Double> {
        Binding(
            get: { state.displayPadding },
            set: { state.padding = $0 }
        )
    }

    private var spacingEnabledBinding: Binding<Bool> {
        Binding(
            get: { state.isSpacingSet },
            set: { state.setSpacingEnabled($0) }
        )
    }

    private var paddingManualBinding: Binding<Bool> {
        Binding(
            get: { !state.isPaddingLinked },
            set: { state.setPaddingLinked(!$0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("Controls")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                PendingChangesIndicator(isVisible: state.hasPendingChanges)
            }

            Form {
                SliderRow(
                    label: "Spacing",
                    value: $state.spacing,
                    onReset: { state.resetSpacingValue() },
                    isDisabled: !state.isSpacingSet,
                    hint: state.isSpacingSet ? nil : "Default",
                    isOn: spacingEnabledBinding,
                    accessibilityLabelText: "Icon spacing",
                    toggleAccessibilityLabel: "Enable custom spacing"
                )

                SliderRow(
                    label: "Padding",
                    value: paddingBinding,
                    onReset: { state.resetPaddingValue() },
                    isDisabled: state.isPaddingLinked,
                    hint: state.isPaddingLinked ? (state.isSpacingSet ? "Auto" : "Default") : nil,
                    isOn: paddingManualBinding,
                    isToggleDisabled: !state.isSpacingSet,
                    accessibilityLabelText: "Selection padding",
                    toggleAccessibilityLabel: "Set padding manually"
                )
            }
            .formStyle(.columns)
        }
    }
}

private struct PendingChangesIndicator: View {
    let isVisible: Bool

    var body: some View {
        Circle()
            .fill(.orange)
            .frame(width: 6, height: 6)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .accessibilityLabel("Pending changes")
            .accessibilityHidden(!isVisible)
    }
}

// MARK: - Action Section

private struct ActionSection: View {
    let state: SpacingState
    @State private var isLogoutAlertPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button("Restore Defaults", action: state.reset)
                    .help("Reset spacing and padding to system defaults")

                Spacer()

                Button("Apply", action: state.apply)
                    .glassButtonStyle()
                    .disabled(!state.hasPendingChanges)
                    .help("Write current values and restart Control Center")

                Button("Apply & Logout") {
                    isLogoutAlertPresented = true
                }
                .glassButtonStyle(prominent: true)
                .disabled(!state.hasPendingChanges)
                .help("Write current values and log out to apply everywhere")
                .confirmationDialog(
                    "Apply & Logout",
                    isPresented: $isLogoutAlertPresented
                ) {
                    Button("Apply & Logout", role: .destructive, action: state.applyAndLogout)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will log you out of your Mac. Make sure you have saved your work in other apps before continuing.")
                }
            }

            Label("Changes will only take effect after logout", systemImage: "info.circle")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Slider Row

private struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let onReset: () -> Void
    var isDisabled: Bool = false
    var hint: String?
    var isOn: Binding<Bool>?
    var isToggleDisabled = false
    var accessibilityLabelText: String?
    var toggleAccessibilityLabel: String?

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 6) {
                Slider(
                    value: $value,
                    in: Double(SpacingService.validRange.lowerBound)...Double(SpacingService.validRange.upperBound),
                    step: 1
                )
                    .disabled(isDisabled)
                    .onChange(of: value) { _, _ in
                        HapticService.tick()
                    }
                    .accessibilityLabel(accessibilityLabelText ?? label)
                    .accessibilityValue(hint ?? "\(Int(value)) pixels")
                    .help("Adjust the \(label.lowercased()) between menu bar icons")

                SliderValueDisplay(hint: hint, value: value)

                Button("Reset \(label.lowercased())", systemImage: "arrow.counterclockwise", action: onReset)
                    .labelStyle(.iconOnly)
                    .glassButtonStyle()
                    .disabled(isDisabled)
                    .help("Reset \(label.lowercased()) to its launch value")

                if let isOn {
                    Toggle(
                        toggleAccessibilityLabel ?? "Enable custom \(label.lowercased())",
                        isOn: isOn
                    )
                    .labelsHidden()
                    .disabled(isToggleDisabled)
                }
            }
        }
    }
}

private struct SliderValueDisplay: View {
    let hint: String?
    let value: Double

    var body: some View {
        if let hint {
            Text(hint)
                .foregroundStyle(.tertiary)
                .frame(minWidth: 30, alignment: .trailing)
        } else {
            Text(Int(value), format: .number)
                .monospacedDigit()
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Availability Helpers

private extension View {
    @ViewBuilder
    func adaptiveGlassEffect() -> some View {
        if #available(macOS 26, *) {
            self.glassEffect(in: .capsule)
        } else {
            self.background(.regularMaterial, in: .capsule)
        }
    }

    @ViewBuilder
    func glassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SpacingState())
}
