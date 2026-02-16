import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import qs.config
import qs.modules.common
import qs.services

PopupWindow {
    id:root
    property var parent
    property bool hovered: hover.hovered
    property bool visibility: parent.popupVisibility
    onVisibilityChanged:console.log(root.visibility)
    property real stack: 1
    property real lastStack: 1
    property bool direction:false
    onStackChanged: {
        if (root.stack === 1) stack.replace(brightness)
        else if (root.stack === 2) stack.replace(volume)
        else stack.replace(network)
        console.log(root.stack, root.lastStack, root.direction)
    }
    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: root.visible = true
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!visibility) root.visible = false
            }
        }
    }
    anchor.item: parent
    anchor.edges: Edges.Left
    anchor.gravity: Edges.Right
    anchor.margins{
        left: 40
        right: 0
        top:-20
        bottom: -20

    }
    implicitWidth: 300
    implicitHeight: 300


    visible: false
    color:"transparent"
    //????
    mask: Region {
        item:content
    }
    // Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
    ItemShadow{}
    Rectangle {
        id:content
        implicitWidth:root.stack === 1 ? 100 : (root.stack === 2 ? 250 : 200)
        implicitHeight: root.stack === 1 ? 100 : (root.stack === 2 ? 80 : 70)
        anchors {
            left:parent.left
            verticalCenter:parent.verticalCenter
            leftMargin: root.visibility ? 5 : -310
            rightMargin: root.visibility ? 20 : 300
            margins:20
        }
        opacity: root.visibility ? 1 : 0
        Behavior on implicitWidth {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on implicitHeight {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        color: Color.base
        radius:15
        
        StackView {
            id: stack
            anchors.fill:parent
            clip:true
            initialItem: brightness
            replaceEnter: Transition {
                NumberAnimation {
                    property: "y"
                    from: root.direction ? stack.height : -stack.height*1.1
                    to: 0
                    duration: 400
                    easing.type: Easing.OutQuart
                }
            }

            replaceExit: Transition {
                NumberAnimation {
                    property: "y"
                    from: 0
                    to: root.direction ? -stack.height : stack.height*1.1
                    duration: 400
                    easing.type: Easing.OutQuart
                }
            }        
        }
        Component {
            id: brightness
            Item {
                objectName: "brightness"
                ClippedFilledCircularProgress {
                    size: 80
                    anchors.centerIn:parent
                    value: Brightness.value
                    colPrimary: Color.surface
                    colSecondary: Color.container_high
                    lineWidth: 5
                    startAngle: -225
                    startAngleSpace: 0
                    sweepDegree: 270
                    backgroundSpace: 20
                    Item {
                        anchors.fill: parent
                        MaterialIcon {
                            anchors.centerIn: parent
                            fill: 1
                            icon: "brightness_2"
                            font.pixelSize: 24
                            color: Color.surface
                        }
                    }
                }
                Text {
                    text:Math.round(Brightness.value * 100) + "%"
                    anchors {
                        bottom:parent.bottom
                        horizontalCenter:parent.horizontalCenter
                        bottomMargin: 5
                    }
                    color: Color.surface
                    font.bold: true
                }
            }
        }
        Component {
            id: volume
            Item {
                objectName: "volume"
                ColumnLayout {
                    spacing:0
                    anchors.margins:10
                    anchors.fill:parent
                    Text {
                        text: Pipewire.defaultAudioSink?.description
                        color: Color.surface
                        font.bold:true
                    }
                    Text {
                        text: Pipewire.defaultAudioSink?.name
                        color: Color.surface_mid
                        font.pointSize:6
                    }
                    Text {
                        text: "Volume: " + Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) + "%"
                        color: Color.secondary
                    }
                    Slider {
                        Layout.fillWidth:true
                        implicitHeight: 10
                        handle: Rectangle {
                            color: "transparent"
                        }
                        background: Item {
                            Rectangle {
                                anchors {
                                    bottom: parent.bottom
                                    top: parent.top
                                    left: parent.left
                                }
                                color: Color.surface

                                implicitWidth: parent.width * Pipewire.defaultAudioSink?.audio.volume
                                radius: 20
                            }
                            Rectangle {
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    right: parent.right
                                }
                                color: Color.container_high
                                opacity:0.5

                                implicitWidth: parent.width * (1 - Pipewire.defaultAudioSink?.audio.volume) - 1
                                radius: 20
                            }
                        }
                    }
                }
            }
        }
        Component {
            id: network
            Item {
                objectName: "network"
                ColumnLayout {
                    anchors.margins:10
                    anchors.fill:parent
                    spacing:0
                    Text {
                        text:`Wifi: ${Network.wifiEnabled ? 'On' : 'Off'}`
                        color: Color.secondary
                    }
                    Text {
                        text:Network.active.ssid
                        font.bold:true
                        color: Color.surface
                        font.pointSize:12
                    }
                    Text {
                        text:"Strength: " +Network.active.strength + "%"
                        color: Color.surface_mid
                    }
                }
            }
        }
    }
}
