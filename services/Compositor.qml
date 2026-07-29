pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services.niri
import qs.services as Services

Singleton {
    readonly property string name: {
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== null)
            return "hyprland"
        if (Quickshell.env("NIRI_SOCKET") !== null)
            return "niri"
        return "generic"
    }

    readonly property bool isHyprland: name === "hyprland"
    readonly property bool isNiri:     name === "niri"

    // Unified actions — modules call these, never compositor-specific IPC directly

    function focusWorkspace(id: int, neighborMode: bool) {
        if (neighborMode === undefined) neighborMode = false
        if (isHyprland) {
            if (neighborMode) Hyprland.dispatch("workspace" + Services.Hyprland.activeWorkspace + id)
            else Hyprland.dispatch("workspace " + id)
        }
        else if (isNiri) {
            if (neighborMode) Niri.focusWorkspace(Niri.focusedWorkspace.idx + id)
            else Niri.focusWorkspace(id)
        }
    }

    readonly property int activeWorkspace: {
        if (isHyprland) {
            return Services.Hyprland.activeWorkspace
        }
        else if (isNiri) {
            return Niri.focusedWorkspace.idx
        }
    }
    readonly property int occupiedWorkspace: {
        if (isHyprland) {
            return Services.Hyprland.occupiedWorkspace
        }
        else if (isNiri) {
            return Niri.focusedWorkspace.windows.length > 0
        }
    }
    readonly property int hasTiling: {
        if (isHyprland) {
            return Services.Hyprland.hasTiling
        }
        else if (isNiri) {
            return Niri.focusedWorkspace.windows.filter(w => !w.isFloating).length
        }
    }
    readonly property var focusedMonitor: {
        if (isHyprland) {
            return Services.Hyprland.focusedMonitor
        }
        else if (isNiri) {
            return Niri.focusedOutput.name
        }
    }

    readonly property bool overview: Niri.overviewOpened
    readonly property var niriWorkspaces: Niri.workspaces
    readonly property var niriWindows: Niri.windows
    //onNiriWindowsChanged: console.log(JSON.stringify(niriWorkspaces, null, 2))
    
    function getOccupiedws(id: int): int {
        if (isHyprland) {
            return Services.Hyprland.topLevel.filter(t => t.workspace && t.workspace.id === id).length
        } else if (isNiri) {
            return Niri.workspaces.find(w => w.idx === id)?.windows.length
        }
    }
}
