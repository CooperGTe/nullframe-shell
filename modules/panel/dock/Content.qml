pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

RowLayout {
    id: root

    property var parentroot

    anchors {
        top:parent.top
        horizontalCenter:parent.horizontalCenter
        topMargin:1
    }

    spacing: 0

    LauncherButton {
        parentPointer: root.parentroot
    }
    Repeater {
        model: root.parentroot.apps

        delegate: AppIcon  {
            id: appIcon
            parentPointer: root.parentroot
        }
    }
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
}
