import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.services
import qs.modules.common
import qs.config

GridLayout {
    id:root
    columns: 4
    rows: 4
    rowSpacing: 8
    columnSpacing: 8
    Layout.fillWidth:true

    Rectangle { 
        Layout.columnSpan: 2
        Layout.fillWidth:true
        implicitHeight: 60; 
        radius:20
        color: Color.container
        MouseArea {
            anchors.fill:parent
            onClicked: Network.toggleWifi()
        }
        RowLayout {
            spacing:0
            anchors.margins: 5
            anchors.fill:parent
            Rectangle {
                implicitWidth:50
                implicitHeight:50
                radius: 15
                color: Network.wifiEnabled ? Color.surface : Color.container_high
                MaterialIcon {
                    icon: "network_wifi"
                    font.pixelSize: 24
                    fill:1
                    anchors.centerIn:parent
                    color: !Network.wifiEnabled ? Color.surface : Color.container
                }
            }
            ColumnLayout {
                spacing:0
                Text {
                    text: Network.active ? Network.active.ssid : "Network"
                    font.family:"monospace"
                    font.bold:true
                    color: Color.surface
                }
                Text {
                    text: Network.active?.active ? "Connected" : "Disconnected"
                    color: Color.surface_low
                }
            }
        }
    }
    Rectangle { 
        Layout.columnSpan: 2
        Layout.fillWidth:true
        implicitHeight: 60; 
        radius:20
        color: Color.container
        MouseArea {
            anchors.fill:parent
        }
        RowLayout {
            spacing:0
            anchors.margins: 5
            anchors.fill:parent
            Rectangle {
                implicitWidth:50
                implicitHeight:50
                radius: 15
                color: Color.container_high
                MaterialIcon {
                    icon: "bluetooth"
                    font.pixelSize: 24
                    anchors.centerIn:parent
                    fill:1
                    color:Color.surface
                }
            }
            ColumnLayout {
                spacing:0
                Text {
                    text: "Bluetooth"
                    font.family:"monospace"
                    font.bold:true
                    color:Color.surface
                }
                Text {
                    text: "Disconnected"
                    color:Color.surface_low
                }
            }
        }
    }
    Rectangle { 
        implicitHeight: 50; 
        radius:20
        Layout.columnSpan:2
        Layout.fillWidth:true
        color: Color.container
        RowLayout {
            anchors.margins:5
            anchors.fill:parent
            Rectangle { 
                implicitHeight: 40
                radius:15
                color: Color.container_high
                Layout.fillWidth:true
                MaterialIcon {
                    anchors.centerIn:parent
                    icon: "coffee"
                    font.pixelSize: 18
                    fill:0
                    color: Color.surface
                }
            }
            Rectangle { 
                implicitHeight: 40; 
                radius: 15
                Layout.fillWidth:true
                color: Color.surface
                MaterialIcon {
                    icon: "dark_mode"
                    anchors.centerIn:parent
                    font.pixelSize: 18
                    fill:1
                    color: Color.base
                }
            }
        }
    }
    Rectangle { 
        implicitHeight: 50; 
        radius:20
        Layout.columnSpan:2
        Layout.fillWidth:true
        color: Color.container
        implicitWidth: root.implicitWidth/12
        RowLayout {
            spacing:0
            anchors.fill:parent
            Rectangle {
                Layout.leftMargin: 5
                implicitWidth: 50
                implicitHeight: 40
                color:Color.container_high
                radius: 15
                MaterialIcon {
                    icon: "nightlight"
                    font.pixelSize: 18
                    anchors.centerIn:parent
                    fill:0
                    color: Color.surface
                }
            }
            ColumnLayout {
                spacing:0
                Text {
                    text: "Night Light"
                    font.family:"monospace"
                    font.bold:true
                    color:Color.surface
                }
                Text {
                    text: "Off"
                    color:Color.surface_low
                }
            }
        }
    }
    //seperator
    Rectangle {
        Layout.columnSpan:4
        implicitHeight:1
        Layout.fillWidth:true
        color: Color.container
    }

    ColumnLayout {
        id:volume
        Layout.columnSpan: 4
        Layout.fillWidth:true
        // Bind the pipewire node so its volume will be tracked
        PwObjectTracker {
            objects: [ Pipewire.defaultAudioSink ]
        }
        Slider { 
            id:volumeSlider
            implicitHeight: 30; 
            Layout.fillWidth:true

            from: 0
            to: 100
            snapMode: Slider.SnapAlways
            stepSize: 1
            value: Pipewire.defaultAudioSink?.audio.volume * 100
            onMoved: {
                Pipewire.defaultAudioSink.audio.volume = this.value / 100
            }
            background: Item {
                width: parent.width
                height: 30
                Rectangle {     // background
                    height: parent.height - 5
                    anchors.verticalCenter:parent.verticalCenter
                    anchors.right:parent.right
                    width: parent.width * (1 - volumeSlider.position -0.024)
                    color: Color.container
                    radius: 10
                    Text {
                        text: `${Math.floor(Pipewire.defaultAudioSink?.audio.volume * 100) ?? 0}%`
                        horizontalAlignment: Text.AlignRight
                        color: Color.surface
                        font.bold: true
                        anchors.rightMargin:10
                        opacity: volumeSlider.position < 0.8 ? 1 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right:parent.right
                        font.pixelSize:12
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                    }
                }
                Rectangle {     // foreground (filled)
                    height: parent.height - 5
                    anchors.verticalCenter:parent.verticalCenter
                    width: parent.width * (volumeSlider.position - 0.01)
                    color: Color.surface
                    radius: 10
                    MaterialIcon {
                        icon: "volume_up"
                        anchors.rightMargin:volumeSlider.position > 0.1 ? 3 : -33
                        anchors.right:parent.right
                        font.pixelSize: 20
                        fill:1
                        color: volumeSlider.position > 0.1 ? Color.base : Color.surface
                        Behavior on anchors.rightMargin {
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                    }
                    Text {
                        text: `${Math.floor(Pipewire.defaultAudioSink?.audio.volume * 100) ?? 0}%`
                        horizontalAlignment: Text.AlignRight
                        color: Color.base
                        font.bold: true
                        anchors.leftMargin:10
                        opacity: volumeSlider.position > 0.8 ? 1 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:parent.left
                        font.pixelSize:12
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                    }
                }
            }

            handle: Rectangle {
                width: 4
                height: 30
                radius: 8
                x: volumeSlider.visualPosition * volumeSlider.width
                color: Color.surface
            }
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    if (event.angleDelta.y < 0)
                    Pipewire.defaultAudioSink.audio.volume = Pipewire.defaultAudioSink?.audio.volume - 0.01
                    else if (event.angleDelta.y > 0)
                    Pipewire.defaultAudioSink.audio.volume = Pipewire.defaultAudioSink?.audio.volume + 0.01
                }
            }
        }
    }
    ColumnLayout {
        Layout.columnSpan: 4
        Layout.fillWidth:true
        Slider { 
            id:brightnessSlider
            implicitHeight: 30; 
            Layout.fillWidth:true
            Component.onCompleted: {
                Brightness.init();
            }

            from: 0
            to: 100
            snapMode: Slider.SnapAlways
            stepSize: 1
            value: Brightness.value * 100
            onMoved: {
                Brightness.set(this.value / 100)
            }
            background: Item {
                width: parent.width
                height: 30
                Rectangle {     // background
                    height: parent.height - 5
                    anchors.verticalCenter:parent.verticalCenter
                    anchors.right:parent.right
                    width: parent.width * (1 - brightnessSlider.position -0.024)
                    color: Color.container
                    radius: 10
                    Text {
                        text: `${Math.round(Brightness.value*100)}%`
                        horizontalAlignment: Text.AlignRight
                        color: Color.surface
                        font.bold: true
                        anchors.rightMargin:10
                        opacity: brightnessSlider.position < 0.8 ? 1 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right:parent.right
                        font.pixelSize:12
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                    }
                }
                Rectangle {     // foreground (filled)
                    height: parent.height - 5
                    anchors.verticalCenter:parent.verticalCenter
                    width: parent.width * (brightnessSlider.position - 0.01)
                    color: Color.surface
                    radius: 10
                    MaterialIcon {
                        icon: "brightness_medium"
                        anchors.right:parent.right
                        anchors.rightMargin: brightnessSlider.position > 0.1 ? 3 : -33
                        font.pixelSize: 20
                        fill:1
                        color: brightnessSlider.position > 0.1 ? Color.base : Color.surface
                        Behavior on anchors.rightMargin {
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                    }
                    Text {
                        text: `${Math.round(Brightness.value*100)}%`
                        horizontalAlignment: Text.AlignRight
                        color: Color.base
                        font.bold: true
                        anchors.leftMargin:10
                        opacity: brightnessSlider.position > 0.8 ? 1 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:parent.left
                        font.pixelSize:12
                        Behavior on opacity {
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.InOutBack
                            }
                        }
                    }
                }
            }

            handle: Rectangle {
                width: 4
                height: 30
                radius: 8
                x: brightnessSlider.visualPosition * brightnessSlider.width
                color: Color.surface
            }
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    if (event.angleDelta.y < 0)
                    Brightness.set(Brightness.value - 0.01)
                    else if (event.angleDelta.y > 0)
                    Brightness.set(Brightness.value + 0.01)
                }
            }
        }
    }
}

