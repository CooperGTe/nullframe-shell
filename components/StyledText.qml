import QtQuick
import qs.config

Text {
    id: root

    property bool invert: false
    property int surface: 0
    property int size: 12

    color: root.invert ? Color.base :
        (root.surface === 0 ? Color.surface : 
        (root.surface === 1 ? Color.primary :
        (root.surface === 2 ? Color.secondary :
        Color.surface_mid)))
    font.bold: root.surface === 0
    font.pixelSize: root.size
}

