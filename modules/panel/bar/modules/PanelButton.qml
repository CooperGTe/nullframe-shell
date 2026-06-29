import qs.components
import QtQuick
import QtQuick.Layouts
import qs.config

MouseArea {
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    implicitWidth: Config.barTotalWidth
    implicitHeight: Config.barTotalWidth
    
    Rectangle {
        id: button

        anchors.centerIn: parent

        implicitHeight: Config.barWidth
        implicitWidth: Config.barWidth

        radius: Config.barWidth

        color: Color.on_tertiary

        MaterialIcon {
            icon: "moon_stars"
            anchors.centerIn: parent
            font.pixelSize: 16 * Config.bar.scale
            fill:1
            color: Color.tertiary
        }
    }
}
