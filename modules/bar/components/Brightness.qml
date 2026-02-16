import qs.modules.common
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id:root
    Layout.alignment: Config.barOrientation ? Qt.AlignVCenter : Qt.AlignHCenter
    implicitHeight: Config.barOrientation ? 20: 20
    implicitWidth: Config.barOrientation ? 20 : 40

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
        anchors { 
            horizontalCenter: !Config.barOrientation ? parent.horizontalCenter : undefined
            verticalCenter: Config.barOrientation ? parent.verticalCenter : undefined
        }
        font.pixelSize: 16
        fill:1
        color: Color.surface
    }
}
