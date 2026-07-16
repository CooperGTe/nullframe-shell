import QtQuick
import QtQuick.Controls

import qs.components
import qs.modules
import qs.config


Button {
    id:root

    required property var parentPointer

    implicitWidth: 35
    implicitHeight: 35

    background: Rectangle {
        anchors.fill:parent
        anchors.margins: 1

        color: Color.surface_container
        radius:5
        opacity: root.hovered ? 1 : 0

        Behavior on opacity { Anim{} }
    }

    MaterialIcon {
        anchors.centerIn:parent
        icon: "apps"
        color: Color.secondary
        font.pixelSize: 32
    }

    onClicked: {
        Global.get(parentPointer.screen).launcherVisibility = !Global.get(parentPointer.screen).launcherVisibility
    }

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
}
