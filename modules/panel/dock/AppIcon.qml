pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland as Hypr

import qs.config

Rectangle {
    id: root

    required property var modelData
    required property var index
    required property var parentPointer

    property bool hovered
    property real size: 40 - 5

    property bool isSeparator: root.modelData.appId === "SEPARATOR"
    property real maxWindowPreviewHeight: 140
    property real maxWindowPreviewWidth: 240

    property bool previewHoverBlocker: false
    property bool previewHover: false
    property bool hoverBlocker: iconHover.hovered || loader.previewHovered || root.previewHoverBlocker
    onHoverBlockerChanged: {
        parentPointer.hoverBlocker = root.hoverBlocker
    }
    Timer {
        id:previewHoverBlocker
        interval:50
        running:false
        repeat:false
        onTriggered:root.previewHoverBlocker = false
    }
    Timer {
        id:previewOpenDelay
        interval:100
        running:false
        repeat:false
        onTriggered:root.previewHoverBlocker = false
    }

    implicitWidth: !isSeparator ? 35 : 1
    implicitHeight: !isSeparator ? 35 : 25

    radius: 10

    color: !isSeparator ? "transparent" : Color.container_high
    //Component.onCompleted: console.log(modelData.toplevels)

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }

    // active indicator
    Rectangle {
        anchors.fill:parent
        anchors.margins: 1
        radius: 5
        color: Color.container_high
        opacity: root.modelData.toplevels.some(function(t) {
            return t.hypr.activated
        }) ? 1 : 0

        Behavior on opacity {
            Anim {}
        }
    }

    //count indicator
    Row {
        anchors.bottomMargin: -3
        anchors.bottom:parent.bottom
        anchors.horizontalCenter:parent.horizontalCenter
        spacing: 3

        Rectangle {
            width:5
            height:5
            radius:5
            color:Color.secondary
            visible: root.modelData.toplevels.length > 0
        }
        Rectangle {
            width:5
            height:5
            radius:5
            color:Color.secondary
            visible: root.modelData.toplevels.length > 1
        }
    }
    IconImage {
        anchors.centerIn:parent
        visible: root.modelData.appId !== "SEPARATOR"
        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(modelData.appId)?.icon, "image-missing")                        
        implicitSize: 30
    }

    MouseArea {
        id:hover
        anchors.fill:parent
        hoverEnabled:root.modelData.appId !== "SEPARATOR"
        
        onClicked: {
            var best = null;
            var bestId = Infinity;

            for (var i = 0; i < root.modelData.toplevels.length; i++) {
                var t = root.modelData.toplevels[i];
                var ipc = t.hypr.lastIpcObject;
                if (!ipc) continue;

                if (ipc.focusHistoryID < bestId) {
                    bestId = ipc.focusHistoryID;
                    best = t;
                }
            }
            if (root.modelData.toplevels.length === 0) {
                DesktopEntries.heuristicLookup(root.modelData.appId).execute()
            }

            if (best && best.wl && !best.min) {
                best.wl.activate();                        
                //console.log("active")
            }
            if (best.min) {
                Quickshell.execDetached([
                    "bash", "-c", "hyprctl --batch 'dispatch movetoworkspacesilent "
                    + Hypr.Hyprland.focusedWorkspace.id + ",address:0x"
                    + best.hypr.address + ";dispatch alterzorder top "
                    + ",address:0x"
                    + best.hypr.address + "'"
                ]),
                parentPointer.showPreviewIndex = 0
                //console.log("mini")
            }
        }
    }
    
    HoverHandler {
        id: iconHover
        onHoveredChanged: {
            root.previewHoverBlocker = true
            previewHoverBlocker.restart()
        }
    }
    LazyLoader {
        id: loader

        property bool previewHovered: item?.previewHovered ?? false

        active: root.modelData.toplevels.length > 0
        PopupWindow {
            id: popup

            property alias previewHovered: previewHover.hovered

            anchor.item: root

            anchor.edges: Edges.Top
            anchor.gravity: Edges.Top

            implicitWidth:previewgrid.implicitWidth
            implicitHeight:previewgrid.implicitHeight

            visible: root.hoverBlocker
            color:"transparent"

            HoverHandler {
                id: previewHover
            }
            RowLayout {
                id:previewgrid
                anchors.fill:parent
                spacing:5
                Repeater {
                    model: root.modelData.toplevels
                    Rectangle {
                        id:previewitem
                        required property var modelData
                        required property var index
                        implicitWidth:screencopyView.implicitWidth
                        implicitHeight:screencopyView.implicitHeight
                        color:Color.base
                        border.width: modelData.min ? 3 : 0
                        border.color: Color.primary
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
                        (
                            Quickshell.execDetached([
                                "bash", "-c", "hyprctl dispatch movetoworkspace "
                                + Hypr.Hyprland.focusedWorkspace.id + ",address:0x"
                                + previewitem.modelData.hypr.address 
                            ]),
                            parentPointer.showPreviewIndex = 0
                        )
                        : previewitem.modelData.wl.activate()
                    }
                }
            }
        }
    }
}
}
