import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.configs

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: wscolumn.implicitHeight + 5
    implicitWidth: 40

    //conf
    property int workspaceLength: Configs.workspacesShowed
    property bool kanji: true

    WheelHandler {
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch("workspace r+1")
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch("workspace r-1")
        }
    }
    
    Rectangle {  // overlay container
        anchors.fill: parent
        anchors.leftMargin:5
        anchors.rightMargin:5
        radius: 30
        color: "#12131F"


        // Active workspace indicator
        Rectangle {
            id: activeIndicator
            z: 0
            radius: 30

            y: ((Hyprland.activeWorkspace - 1) % root.workspaceLength) * 25
            //y: (root.monitor?.activeWorkspace?.id - 1 ?? 0) * 25 - 2

            color: Hyprland.occupiedWorkspace ? "#dfdfff" : "#363745"
            width: 30
            height: 30

            Behavior on y {
                NumberAnimation { duration: 150; easing.type: Easing.OutSine }
            }
            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
        }

        ColumnLayout {
            id: wscolumn
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            y:2 //hack for rectangle toppadding

            Repeater {
                model: root.workspaceLength
                Rectangle {
                    property int wsId: index + (1 + (root.workspaceLength * Math.floor((Hyprland.activeWorkspace - 1) / root.workspaceLength)))
                    property bool active: Hyprland.activeWorkspace === wsId
                    property int toplevelCount: Hyprland.topLevel
                        .filter(t => t.workspace && t.workspace.id === wsId)
                        .length
                        
                    implicitWidth: 25
                    implicitHeight: 25
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
                        color: active ? "#12131F" : toplevelCount ? "#DFDFFF" : "#464755"
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutQuad }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled: true
                        onClicked: Hyprland.dispatch(`workspace ${wsId}`)
                    }
                }
            }
        }
    }
}

