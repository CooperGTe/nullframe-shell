pragma ComponentBehavior: Bound
import Quickshell
import QtQuick.Shapes
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
    implicitWidth: repeater.implicitWidth + 20 +40 // margin
    WlrLayershell.namespace: "dock"
    exclusionMode: Config.dock.ignorePanel ? ExclusionMode.Ignore : ExclusionMode.Normal
    color:"transparent"
    margins.bottom: Config.dock.hideOnTile ? (!Hyprland.hasTiling && Config.dock.enable ? 0 : (panelHover.hovered ? 0 : -35)) : (Config.dock.enable ? 0 : -300)
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
    Behavior on margins.bottom {
        Anim{}
    }
    margins.right:20
    margins.left:20
    property real maxWindowPreviewHeight: 140
    property real maxWindowPreviewWidth: 240
    property real showPreviewIndex: 0
    
    //for lyrics
    property bool panelHovered: panelHover.hovered

    Component.onCompleted: {
        console.log(Hypr.Hyprland.toplevels.values.map(toplevel => toplevel.wayland.appId))
    }
    property list<var> apps: {
        var map = new Map();

        // Pinned App
        const pinnedApps = Config.dock.pinnedApp ?? [];
        for (const appId of pinnedApps) {
            if (!map.has(appId.toLowerCase())) map.set(appId.toLowerCase(), ({
                pinned: true,
                toplevels: []
            }));
        }
        if (pinnedApps.length > 0) {
            map.set("SEPARATOR", { pinned: false, toplevels: [] });
        }

        // Open windows (Hyprland)
        for (const toplevel of Hypr.Hyprland.toplevels.values) {
            const ws = toplevel.workspace;

            if (!ws) continue
            if(ws.id < 0) continue;
            const appId = toplevel.wayland?.appId;
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
            });        
        }

        var values = [];

        for (const [key, value] of map) {
            values.push(appEntryComp.createObject(null, { appId: key, toplevels: value.toplevels, pinned: value.pinned }));
        }

        return values;
    }

    property list<var> minimizeApps: {
        var map = new Map();
        
        map.set("SEPARATOR", { pinned: false, toplevels: [] });

        // Open windows (Hyprland)
        for (const toplevel of Hypr.Hyprland.toplevels.values) {
            const ws = toplevel.workspace;

            var isMin = (ws?.id < 0 && ws.name === "special:min");
            if (ws?.name !== "special:min") continue;
            const appId = toplevel.wayland.appId;
            if (!appId) continue;

            const key = appId.toLowerCase();

            if (!map.has(key)) {
                map.set(key, {
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
    HoverHandler {
        id: panelHover
    }

    Shape {
        id:shape
        anchors.top:parent.top
        implicitWidth: repeater.implicitWidth + 60//????
        property real radius:20
        property bool flatten: height < shape.radius * 2
        property real radiusRounding: shape.flatten ? shape.height / 2 : shape.radius
        height: Config.dock.hideOnTile ? (!Hyprland.hasTiling && Config.dock.enable ?40 : (panelHover.hovered ? 40 : 5)) : (Config.dock.enable ? 40 : 5)

        Behavior on height {
            Anim{}        
        }
        //onHeightChanged:console.log(height)


        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillColor:Color.base
            PathLine { 
                relativeX: 0
                relativeY: shape.height
            }
            PathArc { 
                relativeX: shape.radius
                relativeY:-shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
                direction: PathArc.Counterclockwise
            }
            PathLine { 
                relativeX: 0
                relativeY: shape.height - shape.radiusRounding * 2
            }
            PathArc { 
                relativeX: shape.radius
                relativeY:-shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
            }
            PathLine { 
                relativeX: (shape.width - shape.radius * 4)
                relativeY: 0
            }
            PathArc { 
                relativeX:shape.radius
                relativeY:shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
            }
            PathLine { 
                relativeX: 0
                relativeY: -(shape.height - shape.radiusRounding * 2)
            }
            PathArc { 
                relativeX: shape.radius
                relativeY: shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
                direction: PathArc.Counterclockwise
            }
            PathLine { 
                relativeX: -shape.width
                relativeY: 0
            }
        }        
       RowLayout {
            id:repeater
            spacing: 0
            anchors {
                top:parent.top
                horizontalCenter:parent.horizontalCenter
                topMargin:2
            }
            Repeater {
                model: root.apps.concat(root.minimizeApps)

                delegate:  Rectangle {
                    id:appitem
                    required property var modelData
                    required property var index
                    property bool hovered
                    implicitWidth:appitem.modelData.appId !== "SEPARATOR" ? 35 : 1
                    implicitHeight:appitem.modelData.appId !== "SEPARATOR" ? 35 : 25
                    radius:10
                    color: appitem.modelData.appId !== "SEPARATOR" ? "transparent" : Color.container_high
                    //Component.onCompleted: console.log(modelData.toplevels)
                    IconImage {
                        anchors.centerIn:parent
                        visible: appitem.modelData.appId !== "SEPARATOR"
                        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(modelData.appId)?.icon, "image-missing")                        
                        implicitSize: 30
                    }
                    //indicator
                    Rectangle {
                        width:5
                        height:5
                        radius:5
                        color:Color.surface
                        anchors.bottomMargin: -5
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter:parent.horizontalCenter
                        visible: appitem.modelData.toplevels.length > 0
                    }
                    MouseArea {
                        id:hover
                        anchors.fill:parent
                        hoverEnabled:appitem.modelData.appId !== "SEPARATOR"
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
                            if (appitem.modelData.toplevels.length === 0) {
                                DesktopEntries.heuristicLookup(appitem.modelData.appId).execute()
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
                                root.showPreviewIndex = 0
                                //console.log("mini")
                            }
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
                        active: root.showPreviewIndex === index + 1 && appitem.modelData.toplevels.length > 0
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
                                                (
                                                    Quickshell.execDetached([
                                                        "bash", "-c", "hyprctl dispatch movetoworkspace "
                                                        + Hypr.Hyprland.focusedWorkspace.id + ",address:0x"
                                                        + previewitem.modelData.hypr.address 
                                                    ]),
                                                    root.showPreviewIndex = 0
                                                )
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
