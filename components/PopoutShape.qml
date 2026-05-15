pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

import qs.config

Item {
    id:root

    property int side: 0
    property string baseColor: Color.base
    property real radius:15
    property bool flatten: ((side === 0 || side === 2) ? root.width : root.height) < root.radius * 2
    property real radiusRounding: root.flatten ? ((side === 0 || side === 2) ? root.width : root.height) / 2 : root.radius

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }

    Behavior on implicitWidth {
        Anim{}
    }
    Behavior on implicitHeight {
        Anim{}        
    }

    Loader {
        anchors.fill:parent
        asynchronous: true

        sourceComponent: root.side === 0 ? left 
        : (root.side === 1 ? top 
        : (root.side === 2 ? right
        : bottom))
    }

    Component {
        id: left

        Shape {
            preferredRendererType: Shape.CurveRenderer

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
    }

    Component {
        id: top

        Shape {
             preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                fillColor: root.baseColor
                PathLine { 
                    relativeX: root.width
                    relativeY: 0 
                }
                PathArc { 
                    relativeX: -root.radius
                    relativeY:root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                    direction: PathArc.Counterclockwise
                }
                PathLine { 
                    relativeX: 0
                    relativeY: root.height - root.radiusRounding * 2
                }
                PathArc { 
                    relativeX: -root.radius
                    relativeY: root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                }
                PathLine { 
                    relativeX: -(root.width - root.radius * 4)
                    relativeY: 0
                }
                PathArc { 
                    relativeX: -root.radius
                    relativeY: -root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                }
                PathLine { 
                    relativeX: 0
                    relativeY: -(root.height - root.radiusRounding * 2)
                }
                PathArc { 
                    relativeX: -root.radius
                    relativeY: -root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                    direction: PathArc.Counterclockwise 
                }
            }
        }
    }
    Component {
        id: right

        Shape {
            preferredRendererType: Shape.CurveRenderer
            
            /*ShapePath {
                strokeWidth: 0
                fillColor: root.baseColor
                PathLine { 
                    relativeX: root.width
                    relativeY: 0
                }
                PathArc { 
                    relativeY:root.radius
                    relativeX:-root.radiusRounding
                    radiusY: root.radius
                    radiusX: Math.min(root.radius, root.width)
                }
                PathLine { 
                    relativeX: -(root.width - root.radiusRounding * 2)
                    relativeY: 0
                }
                PathArc { 
                    relativeY:root.radius
                    relativeX:-root.radiusRounding
                    radiusY: root.radius
                    radiusX: Math.min(root.radius, root.width)
                    direction: PathArc.Counterclockwise
                }
                PathLine { 
                    relativeX: 0
                    relativeY: root.height - (root.radius * 4)
                }
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
                    relativeY: -root.height
                }
            }*/
            ShapePath {
                strokeWidth: 0
                fillColor: root.baseColor

                startX: root.width
                startY: 0

                PathArc { 
                    relativeY:root.radius
                    relativeX:-root.radiusRounding
                    radiusY: root.radius
                    radiusX: Math.min(root.radius, root.width)
                }
                PathLine { 
                    relativeX: -(root.width - root.radiusRounding * 2)
                    relativeY: 0
                }
                PathArc { 
                    relativeY:root.radius
                    relativeX:-root.radiusRounding
                    radiusY: root.radius
                    radiusX: Math.min(root.radius, root.width)
                    direction: PathArc.Counterclockwise
                }
                PathLine { 
                    relativeX: 0
                    relativeY: root.height - (root.radius * 4)
                }
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
            }
        }
    }

    Component {
        id: bottom

        Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                fillColor: root.baseColor

                PathLine { 
                    relativeX: 0
                    relativeY: root.height
                }
                PathArc { 
                    relativeX: root.radius
                    relativeY:-root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                    direction: PathArc.Counterclockwise
                }
                PathLine { 
                    relativeX: 0
                    relativeY: -(root.height - root.radiusRounding * 2)
                }
                PathArc { 
                    relativeX: root.radius
                    relativeY:-root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                }
                PathLine { 
                    relativeX: (root.width - root.radius * 4)
                    relativeY: 0
                }
                PathArc { 
                    relativeX:root.radius
                    relativeY:root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                }
                PathLine { 
                    relativeX: 0
                    relativeY: (root.height - root.radiusRounding * 2)
                }
                PathArc { 
                    relativeX: root.radius
                    relativeY: root.radiusRounding
                    radiusX: root.radius
                    radiusY: Math.min(root.radius, root.height)
                    direction: PathArc.Counterclockwise
                }
                PathLine { 
                    relativeX: -root.width
                    relativeY: 0
                }
            }        
        }
    }
}
