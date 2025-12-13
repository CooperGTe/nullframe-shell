import qs.modules.common
import Quickshell.Services.Pipewire
import Quickshell
import QtQuick
import QtQuick.Layouts
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
                "pactl", "set-sink-volume", "@DEFAULT_SINK@" ,"-1%"
            ])
            else if (event.angleDelta.y > 0)
            Quickshell.execDetached([
                "pactl", "set-sink-volume", "@DEFAULT_SINK@" ,"+1%"
            ])
        }
    }

    MaterialIcon {
        icon: "volume_up"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 16
        fill:1
        color: Color.surface
    }
}
