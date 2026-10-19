import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    default property alias content: layout.children

    color: "transparent"
    radius: 0

    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            id: layout
            anchors.margins: 10
            anchors.fill: parent
        }
    }
}
