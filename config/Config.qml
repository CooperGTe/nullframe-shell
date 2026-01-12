pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id:root
    property alias bar: json.bar
    property alias launcher: json.launcher
    property alias desktopWidget: json.desktopWidget
    property alias dock: json.dock
    property alias showLyrics: json.showLyrics
    onBarChanged: console.log(bar.hug)
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
            property Bar bar: Bar {}
            property Launcher launcher: Launcher {}
            property DesktopWidget desktopWidget: DesktopWidget {}
            property Dock dock: Dock {}

            property bool showLyrics: true

            component Bar: JsonObject {
                property real hug: 0
                // 0: false
                // 1: only when tiling
                // 2: only when on empty workspaces 
                // 3: true
                property real workspacesShown: 6
                property bool workspaceKanji: true
            }
            component Launcher: JsonObject {
                property string position: "center"
                // top
                // center
                // bottom
            }
            component DesktopWidget: JsonObject {
                property bool invertClockColor: false
                property bool media: true
            }
            component Dock: JsonObject {
                property bool enable: false
                property bool hideOnTile: true
                property bool ignoreSpecialWorkspace:true
                property real position: 0
                // 0 bottom
                // 1 vertical (opposite of bar)
                property bool onlyShowFloating: false
                property list<string> pinnedApp: ["kitty","thunar"]
                property bool autoHide: false
            }
        }
    }
}
