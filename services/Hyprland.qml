pragma Singleton
import QtQuick
import Quickshell.Hyprland
import Quickshell

Singleton {
    id: root

    //readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)

    //property real activeWorkspace: root.monitor?.activeWorkspace?.id ?? -1
    property real activeWorkspace: Hyprland.focusedWorkspace?.id ?? -1
    property bool occupiedWorkspace: (Hyprland.focusedWorkspace.toplevels?.values || []).length
    property bool hasMaximize: Hyprland.focusedWorkspace.hasFullscreen ?? false
    property real hasTiling: (Hyprland.focusedWorkspace.toplevels?.values || []).filter(toplevel => !toplevel.lastIpcObject.floating).length
    property var topLevel: (Hyprland.toplevels?.values || [])
    property var dispatch: function(arg) {
        return Hyprland.dispatch(arg)
    }
    Connections {
        target: Hyprland

        function onRawEvent() {
            Hyprland.refreshMonitors();
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }
    /*
    property int hasTiling: {
        const arr = Hyprland.focusedWorkspace.toplevels?.values || []
        let c = 0
        for (let t of arr) if (!t.lastIpcObject.floating) c++
        return c
    }*/

    //Component.onCompleted: console.log(activePlayer.trackArtUrl)


    //property real focused: (Hyprland.focusedWorkspace.toplevels?.values?.length > 0 ?? true)
}
