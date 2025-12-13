import qs.modules.common
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: 20
    implicitWidth: 40

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.angleDelta.y < 0)
            Quickshell.execDetached([
                 "brightnessctl", "s", "1%-"
            ])
            else if (event.angleDelta.y > 0)
            Quickshell.execDetached([
                 "brightnessctl", "s", "+1%"
            ])
        }
    }

    MaterialIcon {
        icon: "brightness_2"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 16
        fill:1
        color: Color.surface
    }
}
