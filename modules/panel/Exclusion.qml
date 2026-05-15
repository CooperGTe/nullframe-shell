pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

Item {
    id: root

    required property bool exclusion
    required property var screen

    ExclusionZone {
        anchors.left: true
        exclusiveZone: (Config.bar.position === 0) ? Config.barTotalWidth : Config.bar.borderWidth
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: (Config.bar.position === 1) ? Config.barTotalWidth : Config.bar.borderWidth
    }

    ExclusionZone {
        anchors.right: true
        exclusiveZone: (Config.bar.position === 2) ? Config.barTotalWidth : Config.bar.borderWidth
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: (Config.bar.position === 3) ? Config.barTotalWidth : Config.bar.borderWidth
    }

    component ExclusionZone: PanelWindow {
        WlrLayershell.layer: WlrLayer.Top
        screen: root.screen

        color: "transparent"

        implicitWidth: 1
        implicitHeight: 1

        mask: Region {}
    }
}
