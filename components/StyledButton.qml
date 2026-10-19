import QtQuick

import qs.config
import qs.components

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property bool hovered: false
    property var onClicked

    implicitWidth: contentItem.implicitWidth + (contentItem.anchors.margins * 4)
    implicitHeight: contentItem.implicitHeight + (contentItem.anchors.margins * 2)

    color: Colors.surface_container_high
    radius: 10

    opacity: root.hovered ? 0.8 : 1

    Row {
        id: contentItem

        anchors.margins: 2
        anchors.fill:parent
        anchors.centerIn:parent

        MaterialIcon {
            icon: root.icon
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: root.text != "" ? null : parent.horizontalCenter
        }

        StyledText {
            text: root.text
            surface: 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: if (typeof root.onClicked === "function") root.onClicked()
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }
}
