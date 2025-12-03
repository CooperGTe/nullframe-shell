pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common

Variants {
    model: Quickshell.screens

    Scope {
        id:scope
        required property var modelData
        LazyLoader {
            active:false
            PanelWindow {
                id:root
                screen: scope.modelData
                WlrLayershell.layer: WlrLayer.Overlay
                exclusiveZone:0
                
                implicitWidth: 60*4
                implicitHeight:60
                color: "transparent"
                anchors {
                    top: true
                }

                Rectangle {
                    anchors.fill:parent
                    color:"#080812"
                    bottomRightRadius:20
                    bottomLeftRadius:20
                    RowLayout {
                        anchors.fill:parent
                        anchors.margins:5
                        spacing:5
                        Button {
                            implicitWidth:50
                            implicitHeight:50
                            background: Rectangle {
                                color: "#12131F"
                                radius: 15
                            }
                            MaterialIcon {
                                icon: "power_settings_new"
                                color: "#dfdfff"
                                font.pixelSize:32
                                anchors.centerIn:parent
                            }
                        }
                        Button {
                            implicitWidth:50
                            implicitHeight:50
                            background: Rectangle {
                                color: "#12131F"
                                radius: 15
                            }
                            MaterialIcon {
                                icon: "cached"
                                color: "#dfdfff"
                                font.pixelSize:32
                                anchors.centerIn:parent
                            }
                        }
                        Button {
                            implicitWidth:50
                            implicitHeight:50
                            background: Rectangle {
                                color: "#12131F"
                                radius: 15
                            }
                            MaterialIcon {
                                icon: "lock"
                                color: "#dfdfff"
                                font.pixelSize:32
                                anchors.centerIn:parent
                            }
                        }
                        Button {
                            implicitWidth:50
                            implicitHeight:50
                            background: Rectangle {
                                color: "#12131F"
                                radius: 15
                            }
                            MaterialIcon {
                                icon: "logout"
                                color: "#dfdfff"
                                font.pixelSize:32
                                anchors.centerIn:parent
                            }
                        }
                    }
                }
            }
        }
    }
}
