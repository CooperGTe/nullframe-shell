import QtQuick
import qs.config

Text {
    id: root

    property bool invert: false
    property int surface: 0
    property int size: 12

    color: root.invert ? Color.base :
        (root.surface === 0 ? Color.on_surface : 
        (root.surface === 1 ? Color.on_surface :
        (root.surface === 2 ? Color.secondary :
        Color.outline)))
    font.bold: root.surface === 0
    font.pixelSize: root.size
}

