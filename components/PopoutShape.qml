pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

import qs.config

Shape {
    id:root

    property int side: 0
    property string baseColor: Color.base
    property real radius:15
    property bool flatten: root.width < root.radius * 2
    property real radiusRounding: root.flatten ? root.width / 2 : root.radius

    preferredRendererType: Shape.CurveRenderer

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }

    Behavior on width {
        Anim{}
    }
    Behavior on height {
        Anim{}        
    }

    ShapePath {
        strokeWidth: 0
        fillColor: root.baseColor

        PathArc { 
            relativeY:root.radius
            relativeX:root.radiusRounding
            radiusY: root.radius
            radiusX: Math.min(root.radius, root.width)
            direction: PathArc.Counterclockwise
        }
        PathLine { 
            relativeX: root.width - root.radiusRounding * 2
            relativeY: 0
        }
        PathArc { 
            relativeY:root.radius
            relativeX:root.radiusRounding
            radiusY: root.radius
            radiusX: Math.min(root.radius, root.width)
        }
        PathLine { 
            relativeX: 0
            relativeY: root.height - (root.radius * 4)
        }
        PathArc { 
            relativeY:root.radius
            relativeX:-root.radiusRounding
            radiusY: root.radius
            radiusX: Math.min(root.radius, root.width)
        }
        PathLine { 
            relativeX: -root.width - -root.radiusRounding * 2
            relativeY: 0
        }
        PathArc { 
            relativeY:root.radius
            relativeX:-root.radiusRounding
            radiusY: root.radius
            radiusX:Math.min(root.radius, root.width)
            direction: PathArc.Counterclockwise
        }
    }
}
