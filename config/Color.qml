pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id:root
    property alias base: json.base
    property alias surface: json.surface
    property alias surface_low: json.surface_low
    property alias surface_mid: json.surface_mid
    property alias surface_high: json.surface_high
    property alias container: json.container
    property alias container_high: json.container_high
    property alias primary: json.primary
    property alias secondary: json.secondary
    property alias error: json.error
    property alias error_container: json.error_container

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
            property string primary: "#DFDFFF"
            property string secondary: "#DFDFFF"
            property string error: "#7F1223"
            property string error_container: "#7F1223"
        }
    }
}
