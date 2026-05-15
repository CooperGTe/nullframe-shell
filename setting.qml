import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

FloatingWindow {
    id:root
    minimumSize: Qt.size(200, 50) 
    title: "Nullframe Shell Setting"
    color: Color.base
    ScrollBox {
        anchors.fill:parent
        SectionBox {
            SettingSwitch {
                mainText: "PanelFloat"
                subText: "change float value on the panel"
            }
            SettingSwitch {
                mainText: "Panel Orientation"
                subText: "change panel position"
            }
            SettingSwitch {
                mainText: "Panel Margin"
                subText: "change panel position"
            }
            SettingSwitch {
                mainText: "Panel Hug"
                subText: "change panel position"
            }
        }
        SectionBox {
            SettingSwitch {
                mainText: "PanelFloat"
                subText: "change float value on the panel"
            }
            SettingSwitch {
                mainText: "Panel Orientation"
                subText: "change panel position"
            }
            SettingSwitch {
                mainText: "Panel Margin"
                subText: "change panel position"
            }
            SettingSwitch {
                mainText: "Panel Hug"
                subText: "change panel position"
            }
        }
    }

    component ScrollBox: ScrollView {
        default property alias content: layout.children

        ColumnLayout {
            id: layout
            anchors.margins: 10
            anchors.fill: parent
        }
    }

    component SettingSwitch: Column {
        id: root

        required property string mainText
        property string subText

        anchors.margins: 10
        StyledText {
            text: root.mainText
            surface: 0
        }
        StyledText {
            text: root.subText
            surface: 2
        }
    }
    component SectionBox: Rectangle {
        default property alias content: layout.children
        Layout.fillWidth: true
        implicitHeight: layout.implicitHeight + (layout.anchors.margins * 2)
        color: Color.container
        radius: 10 
        ColumnLayout {
            id: layout
            anchors.margins: 10
            anchors.fill: parent
        }
    }
}
