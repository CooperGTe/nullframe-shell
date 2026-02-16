pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // --- Core battery properties from UPower ---
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice?.percentage ?? 1

    // --- Simplified config values (local replacements) ---
    readonly property var batteryOptions: ({
        automaticSuspend: true,
        low: 25,
        critical: 10,
        suspend: 5,
        full: 95
    })
    readonly property bool allowAutomaticSuspend: batteryOptions.automaticSuspend
    readonly property bool soundEnabled: true

    // --- Derived logic ---
    property bool isLow: available && (percentage <= 30 / 100)
    property bool isCritical: available && (percentage <= 15 / 100)
    property bool isSuspending: available && (percentage <= batteryOptions.suspend / 100)
    property bool isFull: available && (percentage >= batteryOptions.full / 100)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging
    property bool isSuspendingAndNotCharging: allowAutomaticSuspend && isSuspending && !isCharging
    property bool isFullAndCharging: isFull && isCharging

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull
    property real healthPercentage: UPower.displayDevice.healthPercentage
    property bool healthSupported: UPower.displayDevice.healthSupported
    

    // --- Event handlers ---
    onIsLowAndNotChargingChanged: {
        if (!available || !isLowAndNotCharging) return
        Quickshell.execDetached([
            "notify-send",
            "Low battery",
            "Consider plugging in your device",
            "-u", "critical",
            "-a", "Shell"
        ])
        if (soundEnabled) Audio.playSystemSound("dialog-warning")
    }

    onIsCriticalAndNotChargingChanged: {
        if (!available || !isCriticalAndNotCharging) return
        Quickshell.execDetached([
            "notify-send",
            "Critically low battery",
            `Please charge!\nAutomatic suspend triggers at ${batteryOptions.suspend}%`,
            "-u", "critical",
            "-a", "Shell"
        ])
        if (soundEnabled) Audio.playSystemSound("suspend-error")
    }

    /*onIsSuspendingAndNotChargingChanged: {
        if (available && isSuspendingAndNotCharging)
            Quickshell.execDetached(["bash", "-c", "systemctl suspend || loginctl suspend"])
    }

    onIsFullAndChargingChanged: {
        if (!available || !isFullAndCharging) return
        Quickshell.execDetached([
            "notify-send",
            "Battery full",
            "Please unplug the charger",
            "-a", "Shell"
        ])
        if (soundEnabled) Audio.playSystemSound("complete")
    }

    onIsPluggedInChanged: {
        if (!available || !soundEnabled) return
        Audio.playSystemSound(isPluggedIn ? "power-plug" : "power-unplug")
    }*/
}
