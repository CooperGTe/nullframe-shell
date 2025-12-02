pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland as Hypr
import qs.services

// Global Variable
Singleton {
    id:root
    property bool sidePanelVisible: false
    property bool barHug: Hyprland.hasMaximize || root.sidePanelVisible
    property bool mprisSync: true
    onMprisSyncChanged: console.log("resync")
    Hypr.GlobalShortcut {
        name: "sidepanel"
        onPressed: {
            root.sidePanelVisible = !root.sidePanelVisible
        }
    }
}
