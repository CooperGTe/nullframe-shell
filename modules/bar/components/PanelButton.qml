import qs.modules.common
import QtQuick
import QtQuick.Layouts
import qs.modules

MouseArea {
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: 70
    Layout.topMargin: -40
    implicitWidth: 40
    onClicked: {
        Globals.sidePanelVisible = Globals.sidePanelVisible ? false : true
    }
    Rectangle {
        anchors.bottom:parent.bottom
        anchors.horizontalCenter:parent.horizontalCenter
        implicitHeight: 30
        implicitWidth: 30
        radius: 30
        color: "#22232F"
        MaterialIcon {
            icon: "moon_stars"
            anchors.centerIn: parent
            font.pixelSize: 16
            fill:1
            color: "#DFDFFF"
        }
    }
}
