import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow{
    id: root
    color: "transparent"
    property bool isClicked: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    Item {
        anchors.fill: parent

        // Mouse tracking
        MouseArea {
            id: mouseTracker
            anchors.fill: parent
            hoverEnabled: true

            property real offsetX: 0
            property real offsetY: 0

            onPositionChanged: {
                offsetX = (mouseX / width - 0.5) * 2.0
                offsetY = (mouseY / height - 0.5) * 2.0
            }

            onExited: {
                offsetX = 0
                offsetY = 0
            }

            Behavior on offsetX {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutQuart
                }
            }
            Behavior on offsetY {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutQuart
                }
            }
        }

        Image {
            source: "file:///home/katsuro/Dotfiles/wallpaper/Favorites/jpcity.jpg"
            smooth: false
            mipmap: true
            antialiasing:true
            x: mouseTracker.offsetX * 20
            y: mouseTracker.offsetY * 20
            fillMode: Image.PreserveAspectCrop
            height:768
            width:1366
            scale:1.2
        }
    }
}
