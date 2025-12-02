import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // public props
    property int size: 60
    property int lineWidth: 6
    property real value: 0.75
    property color colPrimary: "#685496"
    property color colSecondary: "#F1D3F9"
    property bool enableAnimation: true
    property int animationDuration: 800

    // allow children inside the circle
    default property alias content: contentContainer.data

    implicitWidth: size
    implicitHeight: size

    // internal math
    property real degree: value * 360
    property real centerX: width / 2
    property real centerY: height / 2
    property real arcRadius: size / 2 - lineWidth / 2

    
    // background ring
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: colSecondary
            strokeWidth: lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            startX: centerX
            startY: centerY
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: -90
                sweepAngle: 360
            }
        }
    }

    // main progress arc
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: colPrimary
            strokeWidth: lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            startX: centerX
            startY: centerY
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: -90
                sweepAngle: degree
            }
        }
    }

    // container for user content
    Item {
        id: contentContainer
        anchors.fill: parent
        z: 2
    }
}
