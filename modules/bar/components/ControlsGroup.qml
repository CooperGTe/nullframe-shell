import QtQuick
import QtQuick.Layouts

import qs.config
import qs.modules.common
import "./"
Item {
    id:root
    implicitHeight: ctlctl.implicitHeight + 10
    implicitWidth: 40
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    property bool popupVisibility: hover.hovered || popup.hovered
    HoverHandler {
        id:hover
        cursorShape: Qt.PointingHandCursor
    }
    Rectangle {
        anchors.leftMargin:5
        anchors.rightMargin:5
        anchors.fill:parent
        color: Color.container
        radius: 30
        border.width: 1
        border.color: Color.container_high

        ColumnLayout {
            anchors.centerIn:parent
            id:ctlctl
            anchors.horizontalCenter: parent.horizontalCenter
            spacing:0
            Brightness{
                HoverHandler {
                    id:hover1
                    cursorShape: Qt.PointingHandCursor
                }
            }
            Audio{
                HoverHandler {
                    id:hover2
                    cursorShape: Qt.PointingHandCursor
                }
            }
            //Network
            Item {
                Layout.alignment: Qt.AlignHCenter
                implicitHeight: 20
                implicitWidth:40
                MaterialIcon {
                    icon: "network_wifi_3_bar"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 16
                    fill:1
                    color: Color.surface
                }
                HoverHandler {
                    id:hover3
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
        ControlsPopups {
            id:popup
            parent:root
            function setStack(v) {
                if (v === stack) return
                direction = v > stack
                console.log(direction)
                lastStack = stack
                stack = v
            }

            Connections {
                target: hover1
                function onHoveredChanged() { if (hover1.hovered) popup.setStack(1) }
            }
            Connections {
                target: hover2
                function onHoveredChanged() { if (hover2.hovered) popup.setStack(2) }
            }
            Connections {
                target: hover3
                function onHoveredChanged() { if (hover3.hovered) popup.setStack(3) }
            }        
        }
    }
}
