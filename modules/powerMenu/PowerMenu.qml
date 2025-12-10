pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.modules.common

PanelWindow {
    id:root

    property var scope
    WlrLayershell.namespace: "powermenu"
    property bool visibility
    onVisibilityChanged: if (root.visibility) grab.active = true
    exclusiveZone:0

    WlrLayershell.layer: WlrLayer.Overlay

    implicitWidth: 50*5+30+40 //????
    implicitHeight: 60
    margins.top: root.visibility ? 0 : -60
    Behavior on margins.top {
        SequentialAnimation {
            NumberAnimation { 
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            }
        }
    }

    color: "transparent"

    anchors {
        top: true
    }
    function close() {
        root.scope.powerMenuVisible = false 
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
    Shape {
        id:shape
        implicitWidth: 50*5+30+40 //????

        anchors.bottom:parent.bottom
        height: root.visibility ? 60 : 0
        property real radius:20
        property bool flatten: height < shape.radius * 2
        property real radiusRounding: shape.flatten ? shape.height / 2 : shape.radius
        Behavior on height {
            NumberAnimation { 
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            }
        }
        //onHeightChanged:console.log(height)


        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillColor:"#080812"
            PathLine { 
                relativeX: width
                relativeY: 0 
            }
            PathArc { 
                relativeX: -shape.radius
                relativeY:shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
                direction: PathArc.Counterclockwise
            }
            PathLine { 
                relativeX: 0
                relativeY: shape.height - shape.radiusRounding * 2
            }
            PathArc { 
                relativeX: -shape.radius
                relativeY: shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
            }
            PathLine { 
                relativeX: -(width - shape.radius * 4)
                relativeY: 0
            }
            PathArc { 
                relativeX: -shape.radius
                relativeY: -shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
            }
            PathLine { 
                relativeX: 0
                relativeY: -(shape.height - shape.radiusRounding * 2)
            }
            PathArc { 
                relativeX: -shape.radius
                relativeY: -shape.radiusRounding
                radiusX: shape.radius
                radiusY: Math.min(shape.radius, shape.height)
                direction: PathArc.Counterclockwise 
            }
        }
        RowLayout {
            anchors.bottom:parent.bottom
            anchors.horizontalCenter:parent.horizontalCenter
            anchors.margins:5
            anchors.rightMargin:5+shape.radius
            anchors.leftMargin:5+shape.radius
            Behavior on anchors.topMargin {
                NumberAnimation { 
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
                }
            }
            spacing:5
            component HoverButton: Button {
                property alias iconName: icon.icon
                property real alert: 0
                property real actions: 0
                property var nbtn
                implicitWidth:50
                implicitHeight:50
                background: Rectangle {
                    color: parent.hovered ? "#dfdfff" : "#12131F"
                    radius: parent.hovered ? 30 : 15
                    border.width: parent.activeFocus ? 2 : 0
                    border.color: "#dfdfff"
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    Behavior on radius {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }
                function clickAction() {
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
                    color: !parent.hovered ? "#dfdfff" : "#12131F"
                    fill: !parent.hovered ? 0 : 1
                    font.pixelSize:32
                    anchors.centerIn:parent
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
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
