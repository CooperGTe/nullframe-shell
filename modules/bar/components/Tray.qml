
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick.Effects



ColumnLayout {
    spacing: 8
    Layout.alignment: Qt.AlignHCenter

    Repeater {
        model: SystemTray.items

        IconImage {
            id: icon
            required property SystemTrayItem modelData
            source: modelData.icon
            implicitSize: 16
            layer.enabled: true
            layer.effect: MultiEffect {
                contrast:0.2
                brightness:0
                saturation:-1
            }

            ToolTip {
                id: toolTip
                popupType: Popup.Native
                y: icon.implicitSize * 2
                delay: 500

                contentItem: Text {
                    text: toolTip.text
                    color: "white"
                }

            background: Rectangle {
                color: "#080812"
                radius: 6
            }
        }
        QsMenuAnchor {
            id: menuAnchor
            anchor.item: icon
            anchor.edges: Edges.Left
            anchor.gravity: Edges.Right

            anchor.margins {
                left:35
            }

            menu: icon.modelData.menu
        }

        MouseArea {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            anchors.fill: parent

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton)
                    icon.modelData.activate();
                else if (mouse.button === Qt.RightButton)
                    menuAnchor.open();
            }

            onEntered: {
                if (icon.modelData.tooltipTitle === "")
                    return;

                toolTip.show(icon.modelData.tooltipTitle);
            }

            onExited: toolTip.hide()
            }
        }
    }
}
