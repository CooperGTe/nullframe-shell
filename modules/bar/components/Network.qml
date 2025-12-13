import qs.modules.common
import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: 20
    MaterialIcon {
        icon: "network_wifi_3_bar"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 16
        fill:1
        color: Color.surface
    }
}
