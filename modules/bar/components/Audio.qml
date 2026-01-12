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
    // Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.angleDelta.y < 0) Pipewire.defaultAudioSink.audio.volume += 0.01
            else if (event.angleDelta.y > 0) Pipewire.defaultAudioSink.audio.volume -= 0.01
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
