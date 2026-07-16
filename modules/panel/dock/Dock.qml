import Quickshell
import Quickshell.Hyprland as Hypr
import Quickshell.Wayland
import QtQuick

import qs.config
import qs.services
import qs.components
import qs.modules

PanelWindow{
    id:root

    property bool launcherVisible: Global.get(root.screen).launcherVisibility

    property real showPreviewIndex: 0
    property int floatingHeight: 5

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "dock"
    
    anchors {
        left: true
        bottom: true
        right: true
    }

    implicitHeight: 40 + 20//20 for shadow
    exclusionMode: Config.dock.ignorePanel ? ExclusionMode.Ignore : ExclusionMode.Normal
    color:"transparent"

    property bool isShowed: (Config.dock.hideOnTile ? !Hyprland.hasTiling : false) || panelHover.hovered || root.launcherVisible

    margins.bottom: root.isShowed
        ? 0
        : -35 - Config.bar.borderWidth

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }

    Behavior on margins.bottom {
        Anim{}
    }

    /*Component.onCompleted: {
        console.log(Hypr.Hyprland.toplevels.values.map(toplevel => toplevel.wayland.appId))
    }*/

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
        const pinnedSet = new Set(
            pinnedApps.map(a => a.toLowerCase())
        );

        const hasUnpinned = Array.from(Hypr.Hyprland.toplevels.values)
        .some(t => {
            const appId = t.wayland?.appId;
            return appId && !pinnedSet.has(appId.toLowerCase());
        });

        if (pinnedApps.length > 0 && hasUnpinned) {
            map.set("SEPARATOR", {
                pinned: false,
                toplevels: []
            });
        }
        // Open windows (Hyprland)
        for (const toplevel of Hypr.Hyprland.toplevels.values) {
            const ws = toplevel.workspace;
            
            /*if (!ws) continue
            if(ws.id < 0) continue;
            const appId = toplevel.wayland?.appId;
            if (!appId) continue;*/


            var isMin = (ws?.id < 0 && ws.name === "special:min");
            if (ws?.id < 0 && ws?.name !== "special:min") continue;
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


    ItemShadow {
        transparency: 0.8
    }
    PopoutShape {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.isShowed && Config.dock.floating ? (20 - root.floatingHeight - Config.bar.borderWidth) : 20 //shadow

        // if launcher on and size < 400
        width: !root.launcherVisible 
        ? content.implicitWidth + 60 
        : ((content.implicitWidth + 60) < 440 ? 400 + (Config.dock.floating ? 40 : 60) : content.implicitWidth + 60) //round edge padding
        height: 40

        side: 3
        radius:20

        baseColor: Config.dock.floating ? "transparent" : Color.base

        Behavior on height { Anim{} }
        Behavior on width { Anim{} }

        HoverHandler {
            id: panelHover
            margin:10
            onHoveredChanged: {
                Global.get(root.screen).panelHovered = panelHover.hovered
                console.log(panelHover.hovered, Global.get(root.screen).panelHovered)
            }
        }

        Rectangle {
            radius: 15
            color: Config.dock.floating ? Color.base : "transparent"
            anchors.fill:parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            Content {
                id: content
                parentroot: root
            }
        }
    }
}
