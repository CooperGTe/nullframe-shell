import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.common

FloatingWindow {
    id:root
    minimumSize: Qt.size(150, 50) 
    title: "Nullframe Shell Setting"
    color: Color.base

    RowLayout {
        anchors.fill:parent
        Rectangle {
            Layout.fillHeight: true
            color: Color.container
            implicitWidth: root.width > 400 ? 150 : 50
            Behavior on implicitWidth {
                NumberAnimation { duration: 50; easing.type: Easing.InOutQuad }
            }
            ColumnLayout {
                SectionButton {
                    text: "General"
                    icon: "settings"
                }
                SectionButton {
                    text: "Panel"
                    icon: "dock_to_right"
                }
                SectionButton {
                    text: "Desktop Widget"
                    icon: "widgets"
                }
                SectionButton {
                    text: "Dock"
                    icon: "dock_to_bottom"
                }
                SectionButton {
                    text: "Launcher"
                    icon: "apps"
                }
                SectionButton {
                    text: "OSD"
                }
                SectionButton {
                    text: "Notification"
                    icon: "notifications"
                }
                SectionButton {
                    text: "About"
                    icon: "info"
                }
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
    component SectionButton: RowLayout {
        id:sec
        Layout.fillWidth:true
        Layout.margins: 10
        property string text: "section"
        property string icon: "settings"
        MaterialIcon {
            icon: sec.icon
            anchors { 
                verticalCenter: parent.verticalCenter
            }
            font.pixelSize: 16
            fill:1
            color: Color.secondary
        }
        Text {
            anchors { 
                verticalCenter: parent.verticalCenter
            }
            color: Color.secondary
            text: sec.text
        }
    }
}
