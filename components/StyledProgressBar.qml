import QtQuick

import qs.config

Item {
    id: root

    required property real value

    implicitHeight: 10

    Rectangle {
        anchors {
            bottom: parent.bottom
            top: parent.top
            left: parent.left
        }

        implicitWidth: (parent.width - 10) * root.value +10

        color: Color.primary
        radius: 20
    }

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        implicitWidth: (parent.width - 10) * (1 - root.value) - 3
        color: Color.container_high
        radius: 20
    }

    Rectangle {
        anchors {
            right: parent.right
            margins: 2.5
            verticalCenter:parent.verticalCenter
        }

        implicitWidth: 5
        implicitHeight: 5

        color: Color.primary
        radius: 20
    }
}
