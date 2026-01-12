import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.config

PanelWindow {
    id:root
    property var scope
    property bool visibility

    WlrLayershell.namespace: "controlpanel"
    WlrLayershell.layer: WlrLayer.Overlay

    exclusiveZone:0
    implicitWidth: 360
    color: "transparent"

    margins {
        right: root.visibility ? 0 : -360
    }
    Behavior on margins.right {
        NumberAnimation { 
            duration: 600
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        }
    }
    anchors {
        top: true
        right: true
        bottom: true
    }
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
    Shape {
        id:shape
        property real radius:20

        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        anchors.bottom:parent.bottom
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            fillColor:Color.base
            PathLine { 
                relativeX: width
                relativeY: 0
            }
            PathLine { 
                relativeX: 0
                relativeY: height
            }
            PathLine { 
                relativeX: -width
                relativeY: 0
            }
            PathArc { 
                relativeX: shape.radius
                relativeY: -shape.radius
                radiusX: shape.radius
                radiusY: shape.radius
                direction: PathArc.Counterclockwise
            }
            PathLine { 
                relativeX: 0
                relativeY: -height + (shape.radius * 2)
            }
            PathArc { 
                relativeX: -shape.radius
                relativeY: -shape.radius
                radiusX: shape.radius
                radiusY: shape.radius
                direction: PathArc.Counterclockwise
            }
        }
        RowLayout {
            anchors {
                fill: parent
                leftMargin: shape.radius
            }
            Rectangle {
                Layout.margins: 5
                Layout.fillWidth:true
                Layout.alignment: Qt.AlignTop
                implicitHeight: 120
                radius: 20

                color: "#2F0110"
                border{
                    width: 1
                    color: "#3F0220"
                }
                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: Quickshell.shellDir + "/assets/watermark.png"
                    fillMode: Image.PreserveAspectFit
                    smooth:true
                }
            }
        }
    }
}
