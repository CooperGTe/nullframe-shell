pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland as Hypr
import qs.services

// Global Variable
Singleton {
    id:root
    property bool mprisSync: true
    onMprisSyncChanged: console.log("resync")
}
