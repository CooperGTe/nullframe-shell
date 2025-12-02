import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland


Rectangle {
    id:root
    implicitWidth: 30
    implicitHeight: wscolumn.implicitHeight + 5
    Layout.alignment: Qt.AlignHCenter
    radius: 30
    color: "#12131F"
    property list<bool> workspaceOccupied: []

    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: 6 }, (_, i) => {
            const ws = Hyprland.workspaces.values.find(ws => ws.id === i + 1);
            // if workspace exists, check if it has any toplevels; else false
            return ws ? (ws.toplevels?.values?.length > 0 ?? false) : false;
        });
    }

    Component.onCompleted: updateWorkspaceOccupied()
    Connections { 
        target: Hyprland.workspaces
        function onValuesChanged() { 
            // update occupancy
            updateWorkspaceOccupied(); 

            // connect to toplevel changes for each workspace
            Hyprland.workspaces.values.forEach(ws => {
                if (ws && ws.toplevels && !ws._toplevelsConnected) {
                    ws.toplevels.objectInsertedPost.connect(updateWorkspaceOccupied);
                    ws.toplevels.objectRemovedPost.connect(updateWorkspaceOccupied);
                    ws._toplevelsConnected = true; // prevent duplicate connections
                }
            });
        } 
    }
    Connections { target: Hyprland; function onFocusedWorkspaceChanged() { updateWorkspaceOccupied(); } }

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)

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

    Item {  // overlay container
        anchors.fill: parent
        anchors.topMargin:2

        // Active workspace indicator
        Rectangle {
            id: activeIndicator
            z: 0
            radius: 30
            property int activeId: root.monitor?.activeWorkspace?.id ?? -1
            property bool occupied: root.workspaceOccupied[activeId - 1] ?? false

            y: ((activeId - 1) % 6) * 25 - 2
            //y: (root.monitor?.activeWorkspace?.id - 1 ?? 0) * 25 - 2

            color: occupied ? "#dfdfff" : "#363745"
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

            Repeater {
                model: 6
                Rectangle {
                    property int wsId: index + 1
                    property bool active: root.monitor?.activeWorkspace?.id === wsId
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
                            const mapping={1:"一",2:"二",3:"三",4:"四",5:"五",6:"六"}; 
                            mapping[wsId] || wsId 
                        }
                        color: active ? "#12131F" : workspaceOccupied[wsId - 1] ? "#DFDFFF" : "#464755"
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

