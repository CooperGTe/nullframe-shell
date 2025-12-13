import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.services
import qs.modules.common
import qs.config

GridLayout {
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
        color: Network.wifiEnabled ? Color.surface : Color.container
        MouseArea {
            anchors.fill:parent
            onClicked: Network.toggleWifi()
        }
        ColumnLayout {
            spacing:0
            anchors.fill:parent
            anchors.margins:5
            anchors.leftMargin:15
            MaterialIcon {
                icon: "network_wifi"
                font.pixelSize: 16
                fill:1
                color: !Network.wifiEnabled ? Color.surface : Color.container
            }
            Text {
                text: Network.active ? Network.active.ssid : "Network"
                font.family:"monospace"
                font.bold:true
                color: !Network.wifiEnabled ? Color.surface : Color.container
            }
            Text {
                text: Network.active?.active ? "Connected" : "Disconnected"
                color: !Network.wifiEnabled ? Color.surface_low : Color.surface_mid
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
        ColumnLayout {
            spacing:0
            anchors.fill:parent
            anchors.margins:5
            anchors.leftMargin:15
            MaterialIcon {
                icon: "bluetooth"
                font.pixelSize: 16
                fill:1
                color:Color.surface
            }
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
    Rectangle { 
        implicitHeight: 40
        radius:10
        color: Color.container
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
        radius:10
        Layout.fillWidth:true
        color: Color.container
        MaterialIcon {
            icon: "nightlight"
            anchors.centerIn:parent
            font.pixelSize: 18
            fill:0
            color: Color.surface
        }
    }
    Rectangle { 
        implicitHeight: 40; 
        radius:10
        Layout.fillWidth:true
        color: Color.container
        MaterialIcon {
            icon: "energy_savings_leaf"
            anchors.centerIn:parent
            font.pixelSize: 18
            fill:0
            color: Color.surface
        }
    }
    Rectangle { 
        implicitHeight: 40; 
        radius:10
        Layout.fillWidth:true
        color: Color.container
        MaterialIcon {
            icon: "colorize"
            anchors.centerIn:parent
            font.pixelSize: 18
            fill:0
            color: Color.surface
        }
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
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right:parent.right
                        font.pixelSize:12
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
                        anchors.rightMargin:3
                        anchors.right:parent.right
                        font.pixelSize: 20
                        fill:1
                        color: Color.base
                    }
                }
            }

            handle: Rectangle {
                width: 4
                height: 30
                radius: 8
                x: volumeSlider.visualPosition * volumeSlider.width
                color: Config.surface
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
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right:parent.right
                        font.pixelSize:12
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
                        anchors.rightMargin:3
                        font.pixelSize: 20
                        fill:1
                        color: Color.base
                    }
                }
            }

            handle: Rectangle {
                width: 4
                height: 30
                radius: 8
                x: brightnessSlider.visualPosition * brightnessSlider.width
                color: "#ddd"
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

