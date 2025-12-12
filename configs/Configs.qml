pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id:root
    property alias barHug: json.barHug
    property alias darkClock: json.darkClock
    property alias workspacesShowed: json.workspacesShowed
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
        path: Quickshell.shellDir + "/config.json"

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
            property bool barHug: false
            property bool darkClock: false
            property real workspacesShowed: 6
        }
    }
}
