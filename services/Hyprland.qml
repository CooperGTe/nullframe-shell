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
    property bool hasMaximize: Hyprland.focusedMonitor.activeWorkspace.hasFullscreen ?? false
    property real hasTiling: (Hyprland.focusedWorkspace.toplevels?.values || []).filter(toplevel => !toplevel.lastIpcObject.floating).length
    property string focusedMonitor: Hyprland.focusedMonitor.name
    property var topLevel: (Hyprland.toplevels?.values || [])
    property var dispatch: function(arg) {
        return Hyprland.dispatch(arg)
    }
    // https://github.com/corecathx/whisker/blob/main/services/Hyprland.qml
    /*Connections {
        target: Hyprland

        function onRawEvent() {
            Hyprland.refreshMonitors();
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
        }
    }*/
    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            try {
                const n = event.name;

                if (["workspace", "moveworkspace", "activespecial", "focusedmon"].includes(n)) {
                    Hyprland.refreshWorkspaces();
                    Hyprland.refreshMonitors();
                } else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshWorkspaces();
                } else if (n.includes("mon")) {
                    Hyprland.refreshMonitors();
                } else if (n.includes("workspace")) {
                    Hyprland.refreshWorkspaces();
                } else if (n.includes("window") || n.includes("group") || ["pin", "fullscreen", "changefloatingmode", "minimize"].includes(n)) {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshWorkspaces();
                }
            } catch (e) {
                console.warn("Event handler error:", e);
            }
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
