pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.config

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: !Config.barOrientation ? wscolumn.implicitHeight + 5 : 40
    implicitWidth: Config.barOrientation ? wscolumn.implicitWidth + 5 : 40

    //conf
    property int workspaceLength: Config.bar.workspacesShown
    property bool kanji: Config.bar.workspaceKanji
    property bool roundStart: true
    property bool roundEnd: false

    WheelHandler {
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.angleDelta.y < 0)
                Compositor.focusWorkspace(+1, true)
            else if (event.angleDelta.y > 0 && Compositor.activeWorkspace > 1)
                Compositor.focusWorkspace(-1, true)
        }
    }
    
    Rectangle {  // overlay container
        anchors {
            fill: parent
            leftMargin: !Config.barOrientation ? 5 : 0
            rightMargin: !Config.barOrientation ? 5 : 0
            topMargin: Config.barOrientation ? 5 : 0
            bottomMargin:  Config.barOrientation ? 5 : 0
        }

        radius: 30
        color: "transparent"
        // occupation indicator
        Loader {
            anchors.horizontalCenter:parent.horizontalCenter
            sourceComponent: Config.barOrientation ? horizontal : vertical
            asynchronous: true
        }
        Component {
            id: vertical
            ColumnLayout {
                spacing:0
                y:2 //hack for rectangle toppadding
                Repeater {
                    model: root.workspaceLength
                    Rectangle {
                        required property int index
                        property int wsId: index + (1 + (root.workspaceLength * Math.floor((Compositor.activeWorkspace - 1) / root.workspaceLength)))
                        property int toplevelCount: Compositor.getOccupiedws(wsId)
                        property int topleveltop: if (index % root.workspaceLength != root.workspaceLength - 1) { return Compositor.getOccupiedws(wsId + 1) }
                        property int toplevelbottom: if (index % root.workspaceLength != 0) { return Compositor.getOccupiedws(wsId - 1) }

                        //Component.onCompleted: console.log("wsadads: ", Compositor.getOccupiedws(wsId), index,)

                        Layout.alignment:Qt.AlignHCenter
                        implicitWidth: 26
                        implicitHeight: 26
                        color: toplevelCount ?  Colors.on_secondary : "transparent"

                        bottomLeftRadius: topleveltop ? 0 : 12
                        bottomRightRadius: topleveltop ? 0 : 12
                        topLeftRadius: toplevelbottom ? 0 : 12
                        topRightRadius: toplevelbottom ? 0 : 12
                    }
                }
            }
        }
        Component {
            id: horizontal
            RowLayout {
                spacing:0
                y:2 //hack for rectangle toppadding
                Repeater {
                    model: root.workspaceLength
                    Rectangle {
                        required property int index
                        property int wsId: index + (1 + (root.workspaceLength * Math.floor((Compositor.activeWorkspace - 1) / root.workspaceLength)))
                        property int toplevelCount: Compositor.getOccupiedws(wsId)
                        property int topleveltop: Compositor.getOccupiedws(wsId + 1)
                        property int toplevelbottom: Compositor.getOccupiedws(wsId - 1)

                        Layout.alignment:Qt.AlignHCenter
                        implicitWidth: 26
                        implicitHeight: 26
                        color: toplevelCount ?  Colors.container_high : "transparent"

                        bottomLeftRadius: toplevelbottom ? 0 : 12
                        topLeftRadius: toplevelbottom ? 0 : 12
                        bottomRightRadius: topleveltop ? 0 : 12
                        topRightRadius: topleveltop ? 0 : 12
                    }
                }
            }
        }

        // Active workspace indicator
        Rectangle {
            id: activeIndicator
            z: 0
            radius: 26
            anchors {
                horizontalCenter: !Config.barOrientation ? parent.horizontalCenter : undefined
                verticalCenter: Config.barOrientation ? parent.verticalCenter : undefined
            }
            property int size: Compositor.occupiedWorkspace ? 26 : 18
            property int inversesize: Compositor.occupiedWorkspace ? 0 : 4

            y: !Config.barOrientation ? ((((Compositor.activeWorkspace - 1) % root.workspaceLength) * 26) + 2 + inversesize) : 0
            x: Config.barOrientation ? ((((Compositor.activeWorkspace - 1) % root.workspaceLength) * 26) + 3 + inversesize) : 0
            //y: (root.monitor?.activeWorkspace?.id - 1 ?? 0) * 25 - 2

            color: Compositor.occupiedWorkspace ? Colors.primary : Colors.on_secondary
            width: size
            height: size

            Behavior on y {
                NumberAnimation { duration: 150; easing.type: Easing.OutSine }
            }
            Behavior on x {
                NumberAnimation { duration: 150; easing.type: Easing.OutSine }
            }
            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.OutSine }
            }
            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutSine }
            }
        }

        // Number indicator
        Loader {
            id: wscolumn
            anchors.horizontalCenter:parent.horizontalCenter
            sourceComponent: Config.barOrientation ? horizontalind : verticalind
            asynchronous: true
        }
        Component {
            id: verticalind
            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0
                y:2 //hack for rectangle toppadding

                Repeater {
                    model: root.workspaceLength
                    Rectangle {
                        required property int index
                        property int wsId: index + (1 + (root.workspaceLength * Math.floor((Compositor.activeWorkspace - 1) / root.workspaceLength)))
                        property bool active: Compositor.activeWorkspace === wsId
                        property int toplevelCount: Compositor.getOccupiedws(wsId)

                        implicitWidth: 26
                        implicitHeight: 26
                        radius: 12
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: "Noto Sans CJK JP"
                            font.weight: Font.Bold
                            z: 1
                            text: { 
                                const mapping={
                                    1:"一",
                                    2:"二",
                                    3:"三",
                                    4:"四",
                                    5:"五",
                                    6:"六",
                                    7:"七",
                                    8:"八",
                                    9:"九",
                                    10:"十"
                                }; 
                                return root.kanji ? (mapping[wsId] ?? wsId) : wsId
                            }
                            color: active ? Colors.on_secondary : toplevelCount ? Colors.secondary : Colors.secondary_container
                            Behavior on color {
                                ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true
                            onClicked: Compositor.focusWorkspace(parent.wsId)
                        }
                    }
                }
            }
        }
        Component {
            id: horizontalind
            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0
                y:2 //hack for rectangle toppadding

                Repeater {
                    model: root.workspaceLength
                    Rectangle {
                        required property int index
                        property int wsId: index + (1 + (root.workspaceLength * Math.floor((Compositor.activeWorkspace - 1) / root.workspaceLength)))
                        property bool active: Compositor.activeWorkspace === wsId
                        property int toplevelCount: Compositor.getOccupiedws(wsId)

                        implicitWidth: 26
                        implicitHeight: 26
                        radius: 12
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: "Noto Sans CJK JP"
                            font.weight: Font.Bold
                            z: 1
                            text: { 
                                const mapping={
                                    1:"一",
                                    2:"二",
                                    3:"三",
                                    4:"四",
                                    5:"五",
                                    6:"六",
                                    7:"七",
                                    8:"八",
                                    9:"九",
                                    10:"十"
                                }; 
                                return root.kanji ? (mapping[wsId] ?? wsId) : wsId
                            }
                            color: active ? Colors.container : toplevelCount ? Colors.secondary : Colors.secondary_container
                            Behavior on color {
                                ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: true
                            onClicked: Compositor.focusWorkspace(parent.wsId)
                        }
                    }
                }
            }
        }
    }
}

