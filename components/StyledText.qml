import QtQuick
import qs.config

Text {
    id: root

    property bool invert: false
    property int surface: 0
    property int size: 12

    color: root.invert ? Colors.base :
        (root.surface === 0 ? Colors.on_surface : 
        (root.surface === 1 ? Colors.on_surface :
        (root.surface === 2 ? Colors.secondary :
        Colors.outline)))
    font.bold: root.surface === 0
    font.pixelSize: root.size
}

