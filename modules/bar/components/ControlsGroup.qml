import QtQuick
import QtQuick.Layouts

import qs.config
import qs.modules.common
import "./"
Item {
    id:root
    implicitHeight: !Config.barOrientation ? ctlctl.implicitHeight + 10 : 40
    implicitWidth: Config.barOrientation ? ctlctl.implicitWidth + 10 : 40
    Layout.alignment: Qt.AlignHCenter
    property bool popupVisibility: hover.hovered || popup.hovered

    HoverHandler {
        id:hover
        cursorShape: Qt.PointingHandCursor
    }
    StyledRect {
        anchors { 
            leftMargin:!Config.barOrientation ? 5 : 0
            rightMargin:!Config.barOrientation ? 5 : 0
            topMargin:Config.barOrientation ? 5 : 0
            bottomMargin:Config.barOrientation ? 5 : 0
        }

        border.width: 1
        border.color: Color.container_high

        Loader {
            id:ctlctl
            anchors.centerIn:parent
            sourceComponent: Config.barOrientation ? horizontal : vertical 
        }
        Component {
            id: vertical
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
        }
        Component {
            id: horizontal
            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
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
                    implicitHeight: Config.barOrientation ? 40:20
                    implicitWidth:Config.barOrientation ? 20:40
                    MaterialIcon {
                        icon: "network_wifi_3_bar"
                        anchors { 
                            horizontalCenter: !Config.barOrientation ? parent.horizontalCenter : undefined
                            verticalCenter: Config.barOrientation ? parent.verticalCenter : undefined
                        }
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
