import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config

PanelWindow {
    id:root

    property var scope
    property bool visibility
    onVisibilityChanged: if (root.visibility) grab.active = true
    exclusiveZone:0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    function close() {
        root.scope.powerAlert = 0
        grab.active = false
        action.stop()
        actionTimer.running = false
        actionTimer.stop()
    }
    function actionExec() {
        actionTimer.running = false
        switch (root.scope.powerAlert) {
            case 1: {
                Quickshell.execDetached(["bash", "-c", "systemctl poweroff"]) 
                break
            }
            case 2: {
                Quickshell.execDetached(["bash", "-c", "systemctl reboot"]) 
                break
            }
            case 3: {
                Quickshell.execDetached(["bash", "-c", "hyprctl dispatch exit"]) 
                break
            }
            default: ""; break;
        }
        root.close()
    }


    implicitWidth: 270+40
    implicitHeight: 120+40
    color:"transparent"
    Item {
        Component.onCompleted: {
            parent.layer.enabled = true;
            parent.layer.effect = effectComponent;
        }

        Component {
            id: effectComponent
            MultiEffect {
                shadowEnabled: true
                shadowOpacity: 1
                shadowColor: "black"
                shadowBlur: 1
                shadowScale: 1
            }
        }
    }
    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onActiveChanged: {
            if (!grab.active) {
                root.scope.powerAlert = 0
            }
        }
    }
    Component.onCompleted: {
        root.timelapse = 60
        action.start()
        actionTimer.running = true
    }
    Timer {
        id:action
        interval:60000
        repeat:false
        running:false
        onTriggered: {
            root.actionExec()
        }
    }
    property real timelapse
    Timer {
        id:actionTimer
        interval:1000
        repeat:true
        running:false
        onTriggered: root.timelapse -= 1
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        color: Color.base
        radius: 20
        ColumnLayout {
            anchors.fill:parent
            anchors.margins: 10
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: switch (root.scope.powerAlert) {
                    case 1: "Power Off"; break;
                    case 2: "Reboot"; break;
                    case 3: "Logout"; break;
                    default: ""; break;
                }
                color:Color.surface
                font.bold:true
                font.pixelSize:16
            }
            Text {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 250
                text: switch (root.scope.powerAlert) {
                    case 1: "The system will power off automatically in " + root.timelapse + " seconds."; break;
                    case 2: "The system will reboot automatically in " + root.timelapse + " seconds."; break;
                    case 3: "The system will logout automatically in " + root.timelapse + " seconds."; break;
                    default: ""; break;
                }
                wrapMode:Text.Wrap
                color:Color.surface
                font.pixelSize:12
            }
            RowLayout {
                Layout.fillHeight: true
                Button {
                    id: cancelBtn
                    implicitHeight:32
                    implicitWidth: 1 //equal width
                    Layout.fillWidth:true
                    text: "Cancel"
                    contentItem: Text {
                        text: parent.text
                        color: !parent.hovered ? Color.surface : Color.container
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    background: Rectangle {
                        color: parent.hovered ? Color.surface : Color.container
                        radius: parent.hovered ? 20 : 10
                        border.width: parent.activeFocus ? 2 : 0
                        border.color: Color.surface
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                        Behavior on radius {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }
                    }
                    focus:true
                    Keys.onReturnPressed: root.close()
                    Keys.onEnterPressed: root.close()
                    onClicked: root.close()
                    Keys.onEscapePressed: root.close()

                    KeyNavigation.right: powerBtn
                    KeyNavigation.tab: powerBtn
                }
                Button {
                    id: powerBtn
                    implicitHeight:32
                    implicitWidth: 1
                    Layout.fillWidth:true
                    text: switch (root.scope.powerAlert) {
                        case 1: "Power Off"; break;
                        case 2: "Reboot"; break;
                        case 3: "Logout"; break;
                        default: ""; break;
                    }
                    contentItem: Text {
                        text: parent.text
                        color: !parent.hovered ? Color.surface : Color.container
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    background: Rectangle {
                        color: parent.hovered ? Color.surface : Color.secondary
                        radius: parent.hovered ? 20 : 10
                        border.width: parent.activeFocus ? 2 : 0
                        border.color: Color.surface
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                        Behavior on radius {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }
                    }

                    KeyNavigation.left: cancelBtn
                    KeyNavigation.backtab: cancelBtn
                    Keys.onReturnPressed: root.actionExec()
                    Keys.onEnterPressed: root.actionExec()
                    onClicked: root.actionExec()
                    Keys.onEscapePressed: root.close()
                }
            }
        }
    }
}
