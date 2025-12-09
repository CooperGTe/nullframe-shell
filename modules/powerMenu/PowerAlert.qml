import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id:root

    property var scope
    property bool visibility
    onVisibilityChanged: if (root.visibility) grab.active = true
    exclusiveZone:0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    function close() {
        root.scope.powerAlert = 0
        grab.active = false
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
    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        color: "#080812"
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
                color:"#dfdfff"
                font.bold:true
                font.pixelSize:16
            }
            Text {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 250
                text: switch (root.scope.powerAlert) {
                    case 1: "The system will power off automatically in 60 seconds."; break;
                    case 2: "The system will reboot automatically in 60 seconds."; break;
                    case 3: "The system will logout automatically in 60 seconds."; break;
                    default: ""; break;
                }
                wrapMode:Text.Wrap
                color:"#dfdfff"
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
                        color: !parent.hovered ? "#dfdfff" : "#12131F"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#dfdfff" : "#12131F"
                        radius: parent.hovered ? 20 : 10
                        border.width: parent.activeFocus ? 2 : 0
                        border.color: "#dfdfff"
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                        Behavior on radius {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }
                    }
                    Keys.onReturnPressed: close()
                    Keys.onEnterPressed: close()
                    onClicked: close()
                    Keys.onEscapePressed: close()

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
                        color: !parent.hovered ? "#dfdfff" : "#12131F"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#dfdfff" : "#12131F"
                        radius: parent.hovered ? 20 : 10
                        border.width: parent.activeFocus ? 2 : 0
                        border.color: "#dfdfff"
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                        Behavior on radius {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }
                    }

                    KeyNavigation.left: cancelBtn
                    KeyNavigation.backtab: cancelBtn
                    Keys.onEscapePressed: close()
                }
            }
        }
    }
}
