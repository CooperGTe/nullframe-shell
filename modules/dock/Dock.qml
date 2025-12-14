pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland as Hypr
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services

PanelWindow{
    id:root
    WlrLayershell.layer: WlrLayer.Top
    implicitHeight: 40
    implicitWidth: repeater.implicitWidth + 20 // margin
    exclusiveZone:0
    color:"transparent"
    visible: Config.dock.enable
    property real maxWindowPreviewHeight: 140
    property real maxWindowPreviewWidth: 240
    property real showPreviewIndex: 0

    Component.onCompleted: {
        console.log(Hypr.Hyprland.toplevels.values.map(toplevel => toplevel.wayland.appId))
    }
    property list<var> apps: {
        var map = new Map();

        // Open windows (Hyprland)
        for (const toplevel of Hypr.Hyprland.toplevels.values) {
            const ws = toplevel.workspace;
            if (!ws) continue;

            var isMin = (ws.id < 0 && ws.name === "special:min");

            if (ws.id < 0 && ws.name !== "special:min") continue;
            const appId = toplevel.wayland.appId;
            if (!appId) continue;

            const key = appId.toLowerCase();

            if (!map.has(key)) {
                map.set(key, {
                    pinned: false,
                    toplevels: []
                });
            }

            map.get(key).toplevels.push({
                hypr: toplevel,          // HyprlandToplevel (has address)
                wl: toplevel.wayland,     // Wayland Toplevel (for screencopy)
                min: isMin
            });        
        }

        var values = [];

        for (const [key, value] of map) {
            values.push(appEntryComp.createObject(null, { appId: key, toplevels: value.toplevels, pinned: value.pinned }));
        }

        return values;
    }
    component TaskbarAppEntry: QtObject {
        id: wrapper
        required property string appId
        required property list<var> toplevels
        required property bool pinned
    }
    Component {
        id: appEntryComp
        TaskbarAppEntry {}
    }

    anchors {
        bottom: true
    }
    Timer {
        id:hideTimer
        interval: 1000
        repeat: false
        running:false
        onTriggered: root.showPreviewIndex = 0
    }

    Rectangle {
        anchors.fill:parent
        color:"transparent"
        topRightRadius: 20
        topLeftRadius: 20
        RowLayout {
            id:repeater
            spacing: 0
            anchors.centerIn:parent
            Repeater {
                function uniqueSortedAppIds(toplevels) {
                    var ids = toplevels
                    .map(function (t) { return t.wayland.appId; })
                    .sort(function (a, b) { return a.localeCompare(b); });

                    var out = [];
                    for (var i = 0; i < ids.length; i++) {
                        if (i === 0 || ids[i] !== ids[i - 1])
                        out.push(ids[i]);
                    }
                    return out;
                }
                model: root.apps

                delegate:  Rectangle {
                    id:appitem
                    required property var modelData
                    required property var index
                    property bool hovered
                    implicitWidth:35
                    implicitHeight:35
                    radius:10
                    color: "transparent"
                    //Component.onCompleted: console.log(modelData.toplevels)
                    IconImage {
                        anchors.centerIn:parent
                        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(modelData.appId)?.icon, "image-missing")                        
                        implicitSize: 30
                    }
                    MouseArea {
                        id:hover
                        anchors.fill:parent
                        hoverEnabled:true
                        onEntered: {
                            root.showPreviewIndex = index + 1
                            hideTimerDelay.start()
                            //console.log(appitem.modelData.toplevels.map(t => t.hypr.lastIpcObject.focusHistoryID))
                        }
                        onExited: {
                            hideTimer.start()
                        }
                        onClicked: {
                            var best = null;
                            var bestId = Infinity;

                            for (var i = 0; i < appitem.modelData.toplevels.length; i++) {
                                var t = appitem.modelData.toplevels[i];
                                var ipc = t.hypr.lastIpcObject;
                                if (!ipc) continue;

                                if (ipc.focusHistoryID < bestId) {
                                    bestId = ipc.focusHistoryID;
                                    best = t;
                                }
                            }
                            if (best.min) {
                                Quickshell.execDetached([
                                    "bash", "-c", "hyprctl dispatch movetoworkspacesilent "
                                    + Hypr.Hyprland.focusedWorkspace.id + ",address:0x"
                                    + best.hypr.address 
                                ])
                                //console.log("mini")
                            }
                            if (best && best.wl && !best.min) {
                                best.wl.activate();                        
                                //console.log("active")
                            }
                            

                            console.log(best.hypr.lastIpcObject.focusHistoryID)
                        }
                    }
                    Timer { // ??????????
                        id:hideTimerDelay
                        interval:50
                        running:false
                        repeat:false
                        onTriggered:hideTimer.stop()
                    }
                    LazyLoader {
                        active: root.showPreviewIndex === index + 1
                        PopupWindow {
                            anchor.window: root
                            anchor.rect.x: (35 * appitem.index)-(this.implicitWidth/2)+28
                            anchor.rect.y: -145
                            implicitWidth:previewgrid.implicitWidth
                            implicitHeight:previewgrid.implicitHeight
                            visible: true
                            color:"transparent"
                            MouseArea {
                                id:hovera
                                anchors.fill:parent
                                hoverEnabled:true
                                onEntered: {
                                    hideTimer.stop()
                                }
                                onExited: {
                                    root.showPreviewIndex = 0
                                }
                            }
                            RowLayout {
                                id:previewgrid
                                anchors.fill:parent
                                spacing:5
                                Repeater {
                                    model: appitem.modelData.toplevels
                                    Rectangle {
                                        id:previewitem
                                        required property var modelData
                                        required property var index
                                        implicitWidth:screencopyView.implicitWidth
                                        implicitHeight:screencopyView.implicitHeight
                                        color:Color.base
                                        border.width: modelData.min ? 3 : 0
                                        border.color: Color.surface
                                        radius:10
                                        /*Component.onCompleted: console.log("hyprctl dispatch movetoworkspacesilent "
                                            + previewitem.index + ",address:0x"
                                            + previewitem.modelData.hypr.address
                                        )
                                        console.log(modelData.min)*/
                                        ScreencopyView {
                                            id: screencopyView
                                            anchors.fill:parent
                                            anchors.margins:5
                                            captureSource:previewitem.modelData.wl
                                            live: true
                                            constraintSize: Qt.size(root.maxWindowPreviewWidth, root.maxWindowPreviewHeight)
                                        }
                                        MouseArea {
                                            anchors.fill:parent
                                            //onClicked: 
                                            onClicked: previewitem.modelData.min ? 
                                                Quickshell.execDetached([
                                                    "bash", "-c", "hyprctl dispatch movetoworkspacesilent "
                                                    + Hypr.Hyprland.focusedWorkspace.id + ",address:0x"
                                                    + previewitem.modelData.hypr.address 
                                                ])
                                                : previewitem.modelData.wl.activate()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
