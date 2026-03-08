pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id:root
    property alias base: json.base
    property alias container: json.container
    property alias container_high: json.container_high
    property alias container_highest: json.container_highest

    property alias primary: json.primary
    property alias on_primary: json.on_primary
    property alias primary_container: json.primary_container
    property alias on_primary_container: json.on_primary_container

    property alias secondary: json.secondary
    property alias on_secondary: json.on_secondary
    property alias secondary_container: json.secondary_container
    property alias on_secondary_container: json.on_secondary_container

    property alias tertiary: json.tertiary
    property alias on_tertiary: json.on_tertiary
    property alias tertiary_container: json.tertiary_container
    property alias on_tertiary_container: json.on_tertiary_container

    property alias error: json.error
    property alias error_container: json.error_container

    property alias surface: json.surface
    property alias surface_low: json.surface_low
    property alias surface_mid: json.surface_mid
    property alias surface_high: json.surface_high

    Timer {
        id: fileReloadTimer
        interval: 50
        repeat: false
        onTriggered: {
            configFileView.reload()
        }
    }
    FileView {
        id:configFileView
        path: Quickshell.shellDir + "/colors.json"

        // when changes are made on disk, reload the file's content
        watchChanges: true
        onFileChanged: fileReloadTimer.restart()

        // when changes are made to properties in the adapter, save them
        onAdapterUpdated: writeAdapter()
        onLoadFailed: err => {
            if (err == FileViewError.FileNotFound) {
                writeAdapter();
                console.log("file not found")
            }
        }
        JsonAdapter {
            id:json
            property string base: "#080812"
            property string surface: "#DFDFFF"
            property string surface_low: "#464755"
            property string surface_mid: "#8f8f9f"
            property string surface_high: "#DFDFFF"
            property string container: "#12131F"
            property string container_high: "#22232F"
            property string container_highest: "#22232F"
            //wip
            property string primary: "#DFDFFF"
            property string on_primary: "#DFDFFF"
            property string primary_container: "#DFDFFF"
            property string on_primary_container: "#DFDFFF"
            property string secondary: "#DFDFFF"
            property string on_secondary: "#DFDFFF"
            property string secondary_container: "#DFDFFF"
            property string on_secondary_container: "#DFDFFF"
            property string tertiary: "#DFDFFF"
            property string on_tertiary: "#DFDFFF"
            property string tertiary_container: "#DFDFFF"
            property string on_tertiary_container: "#DFDFFF"
            property string error: "#7F1223"
            property string error_container: "#7F1223"
        }
    }
}
