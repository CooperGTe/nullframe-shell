pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.components
import qs.config

PanelWindow {
    id:root

    property var scope
    property bool visibility

    onVisibilityChanged: if (root.visibility) grab.active = true

    WlrLayershell.namespace: "powermenu"
    WlrLayershell.layer: WlrLayer.Overlay

    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 50*5+30+40 //????
    implicitHeight: 60

    margins.top: loader.active ? Config.bar.borderWidth : -60
    anchors {
        top: true
    }

    color: "transparent"

    function close() {
        grab.active = false
        root.scope.powerMenuVisible = false 
    }

    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: {
                    loader.active = true
                }
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!root.visibility) {
                    loader.active = false
                }
            }
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onActiveChanged: {
            if (!grab.active) {
                root.close()
            }
        }
    }

    Loader {
        id:loader

        anchors.fill:parent

        PopoutShape {
            id:shape

            side:1
            implicitHeight: root.visibility ? 55 : 0
            implicitWidth: row.implicitWidth + (radius * 2) + (row.anchors.margins * 2)

            anchors.top:parent.top

            RowLayout {
                id: row
                spacing:5

                anchors {
                    bottom:parent.bottom
                    horizontalCenter:parent.horizontalCenter
                    margins:5
                }

                Behavior on anchors.topMargin {
                    NumberAnimation { 
                        duration: 400
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
                    }
                }
                HoverButton {
                    iconName: "power_settings_new"
                    alert: 1
                    focus:true
                    id:poweroff
                    KeyNavigation.right: reboot
                    KeyNavigation.tab: reboot
                    Keys.onEscapePressed: root.close()
                }
                HoverButton {
                    iconName: "refresh"
                    alert: 2
                    id:reboot
                    KeyNavigation.right: sleep
                    KeyNavigation.tab: sleep
                    Keys.onEscapePressed: root.close()
                }
                HoverButton {
                    iconName: "mode_night"
                    actions: 1
                    id:sleep
                    KeyNavigation.right: lock
                    KeyNavigation.tab: lock
                    Keys.onEscapePressed: root.close()
                }
                HoverButton {
                    iconName: "lock"
                    actions: 2
                    id:lock
                    KeyNavigation.right: logout
                    KeyNavigation.tab: logout
                    Keys.onEscapePressed: root.close()
                }
                HoverButton {
                    iconName: "logout"
                    alert: 3
                    id:logout
                    KeyNavigation.right: poweroff
                    KeyNavigation.tab: poweroff
                    Keys.onEscapePressed: root.close()
                }
            }

        }
    }
    // what the fuck is this? how did i wrote this?
    component HoverButton: Button {
        property alias iconName: icon.icon

        property real alert: 0
        property real actions: 0
        property var nbtn

        implicitWidth:50
        implicitHeight:50

        background: Rectangle {
            color: parent.hovered ? Color.primary : Color.surface_container
            radius: parent.hovered ? 30 : 10
            border.width: parent.activeFocus ? 2 : 0
            border.color: Color.primary
            Behavior on color {
                ColorAnimation { duration: 100 }
            }
            Behavior on radius {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
        function clickAction() {
            grab.active = false
            root.scope.powerAlert = this.alert
            switch (this.actions) {
                case 1: {
                    Quickshell.execDetached(["bash", "-c", "systemctl suspend"]); 
                    root.scope.powerMenuVisible = false
                    break;
                }
                case 2: {
                    Quickshell.execDetached(["bash", "-c", "qs ipc call lockscreen lock"])
                    root.scope.powerMenuVisible = false
                    break;
                }
                default: break;
            }
        }
        onClicked: clickAction()
        Keys.onReturnPressed: clickAction()
        Keys.onEnterPressed: clickAction()
        MaterialIcon {
            id:icon
            color: !parent.hovered ? Color.primary : Color.container
            fill: !parent.hovered ? 0 : 1
            font.pixelSize:32
            anchors.centerIn:parent
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
}
