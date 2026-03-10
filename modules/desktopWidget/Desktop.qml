import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.services
import qs.components
import qs.config

Scope {
    id: scope
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id:root
            // Layer props
            screen: modelData
            exclusionMode: ExclusionMode.Normal
            WlrLayershell.layer: WlrLayer.Bottom
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"

            // focus handler
            property real wsch: Hyprland.activeWorkspace
            onWschChanged: {
                popout.visible = false
                grab.active = false
            }

            MouseArea {
                anchors.fill:parent
                acceptedButtons: Qt.RightButton
                onPressed: (mouse)=> {
                    debugger;
                    if (mouse.button === Qt.RightButton) {
                        popout.x = mouse.x
                        popout.y = mouse.y
                        popout.visible = true
                        grab.active = true
                    }
                }
            }

            PopupWindow {
                id: popout

                property int x: 0
                property int y: 0

                anchor.window: root
                anchor.rect.x: popout.x
                anchor.rect.y: popout.y
                
                width: 100
                height: 100


                HyprlandFocusGrab {
                    id: grab
                    windows: [ popout ]
                    onCleared: {
                        popout.visible = false
                    }
                }
            }
        }
    }
}
