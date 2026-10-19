pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias base: json.base

    //old code fallback
    property alias container: json.surface_container
    property alias container_high: json.surface_container_high
    property alias container_highest: json.surface_container_highest

    property alias surface_dim: json.surface_dim
    property alias surface: json.surface
    property alias surface_bright: json.surface_bright

    property alias surface_container_lowest: json.surface_container_lowest
    property alias surface_container_low: json.surface_container_low
    property alias surface_container: json.surface_container
    property alias surface_container_high: json.surface_container_high
    property alias surface_container_highest: json.surface_container_highest

    property alias on_surface: json.on_surface
    property alias on_surface_variant: json.on_surface_variant

    property alias inverse_primary: json.inverse_primary
    property alias surface_tint: json.surface_tint

    property alias primary: json.primary
    property alias on_primary: json.on_primary
    property alias primary_container: json.primary_container
    property alias on_primary_container: json.on_primary_container
    property alias primary_fixed: json.primary_fixed
    property alias primary_fixed_dim: json.primary_fixed_dim
    property alias on_primary_fixed: json.on_primary_fixed
    property alias on_primary_fixed_variant: json.on_primary_fixed_variant

    property alias secondary: json.secondary
    property alias on_secondary: json.on_secondary
    property alias secondary_container: json.secondary_container
    property alias on_secondary_container: json.on_secondary_container
    property alias secondary_fixed: json.secondary_fixed
    property alias secondary_fixed_dim: json.secondary_fixed_dim
    property alias on_secondary_fixed: json.on_secondary_fixed
    property alias on_secondary_fixed_variant: json.on_secondary_fixed_variant

    property alias tertiary: json.tertiary
    property alias on_tertiary: json.on_tertiary
    property alias tertiary_container: json.tertiary_container
    property alias on_tertiary_container: json.on_tertiary_container
    property alias tertiary_fixed: json.tertiary_fixed
    property alias tertiary_fixed_dim: json.tertiary_fixed_dim
    property alias on_tertiary_fixed: json.on_tertiary_fixed
    property alias on_tertiary_fixed_variant: json.on_tertiary_fixed_variant

    property alias error: json.error
    property alias on_error: json.on_error
    property alias error_container: json.error_container
    property alias on_error_container: json.on_error_container

    property alias outline: json.outline
    property alias outline_variant: json.outline_variant

    property alias shadow: json.shadow
    property alias scrim: json.scrim

    Timer {
        id: fileReloadTimer
        interval: 50
        repeat: false
        onTriggered: configFileView.reload()
    }

    FileView {
        id: configFileView
        path: Quickshell.shellDir + "/colors.json"

        watchChanges: true
        onFileChanged: fileReloadTimer.restart()

        onAdapterUpdated: writeAdapter()
        onLoadFailed: err => {
            if (err == FileViewError.FileNotFound) {
                writeAdapter()
                console.log("file not found")
            }
        }

        JsonAdapter {
            id: json

            // Surface backgrounds
            property string base: "#080812"
            property string surface_dim: "#080812"
            property string surface: "#080812"
            property string surface_bright: "#13141F"

            // Surface containers
            property string surface_container_lowest: "#05060F"
            property string surface_container_low: "#0D0E1A"
            property string surface_container: "#12131F"
            property string surface_container_high: "#1C1D2A"
            property string surface_container_highest: "#272835"

            // Surface text & icons
            property string on_surface: "#E3E1F0"
            property string on_surface_variant: "#C7C5D4"

            // Inverse
            property string inverse_primary: "#4A4B8C"
            property string surface_tint: "#C3C0FF"

            // Primary
            property string primary: "#C3C0FF"
            property string on_primary: "#25257A"
            property string primary_container: "#3C3C92"
            property string on_primary_container: "#E3E0FF"
            property string primary_fixed: "#E3E0FF"
            property string primary_fixed_dim: "#C3C0FF"
            property string on_primary_fixed: "#0D0D61"
            property string on_primary_fixed_variant: "#3C3C92"

            // Secondary
            property string secondary: "#C6C3DC"
            property string on_secondary: "#2F2F45"
            property string secondary_container: "#46455C"
            property string on_secondary_container: "#E2DFF9"
            property string secondary_fixed: "#E2DFF9"
            property string secondary_fixed_dim: "#C6C3DC"
            property string on_secondary_fixed: "#1B1A2F"
            property string on_secondary_fixed_variant: "#46455C"

            // Tertiary
            property string tertiary: "#EAB8C8"
            property string on_tertiary: "#4A2232"
            property string tertiary_container: "#633848"
            property string on_tertiary_container: "#FFD9E3"
            property string tertiary_fixed: "#FFD9E3"
            property string tertiary_fixed_dim: "#EAB8C8"
            property string on_tertiary_fixed: "#310D1E"
            property string on_tertiary_fixed_variant: "#633848"

            // Error
            property string error: "#FFB4AB"
            property string on_error: "#7F1223"
            property string error_container: "#9B1226"
            property string on_error_container: "#FFD9D9"

            // Outline
            property string outline: "#918FA1"
            property string outline_variant: "#46455C"

            // Utility
            property string shadow: "#000000"
            property string scrim: "#000000"
        }
    }
}
