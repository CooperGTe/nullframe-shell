import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.services
import qs.config
import qs.components

Item {
    id: root

    property var weather
    
    Layout.fillHeight:true
    Layout.fillWidth: true

    //Component.onCompleted: console.log(Config.weatherLocationName.replace(" ", "+"))

    ColumnLayout {
        anchors.fill:parent
        spacing:5
        Rectangle {
            implicitHeight:24
            Layout.fillWidth: true

            color: Color.surface_container
            radius:10

            Row {
                anchors.left:parent.left
                anchors.verticalCenter:parent.verticalCenter
                anchors.leftMargin: 10
                spacing: 10

                StyledText {
                    text: `${Weather.weather.nearest_area[0].areaName[0].value}`
                }
                StyledText {
                    text: `${Weather.lastUpdateTime} last updated`
                    surface:3
                }
            }
            StyledButton {
                anchors.right:parent.right
                text: "refresh"
                icon: "refresh"
                onClicked: () => {
                    Weather.fetch(false)
                }
            }
        }
        Rectangle {
            color: Color.surface_container
            radius:10
            implicitHeight: 100
            Layout.fillWidth: true

            Item {
                anchors.fill:parent
                anchors.margins:10
                Row {
                    anchors.verticalCenter:parent.verticalCenter
                    spacing: 5
                    MaterialIcon {
                        icon: Weather.icon
                        color: Color.secondary
                        font.pixelSize: 64
                    }
                    Column {
                        StyledText {
                            text: Weather.weatherDesc
                        }
                        Row {
                            spacing: 5
                            Column {
                                StyledText {
                                    surface:2
                                    text: ` : ${Weather.weather.current_condition[0].temp_C}°C (${Weather.weather.current_condition[0].FeelsLikeC}°C)`
                                    font.family: "JetbrainsMono Nerd Font Mono"
                                }
                                StyledText {
                                    surface:2
                                    text: ` : ${Weather.humidity}%`
                                    font.family: "JetbrainsMono Nerd Font Mono"
                                }
                                StyledText {
                                    surface:2
                                    text: `󰖝 : ${Weather.windspeedKmph} km/h ${Weather.winddir16Point}`
                                    font.family: "JetbrainsMono Nerd Font Mono"
                                }
                            }
                            Column {
                                StyledText {
                                    surface:2
                                    text: `󰊚  : ${Weather.pressure}hPa`
                                    font.family: "JetbrainsMono Nerd Font Mono"
                                }
                                StyledText {
                                    surface:2
                                    text: `UV : ${Weather.uvIndex}`
                                    font.family: "JetbrainsMono Nerd Font Mono"
                                }
                                StyledText {
                                    surface:2
                                    text: `󰈈  : ${Weather.visibility} km`
                                    font.family: "JetbrainsMono Nerd Font Mono"
                                }
                            }
                        }
                    }
                }
            }
        }
        Item {
            id:hourlyw
            Layout.fillWidth:true
            Layout.fillHeight:true
            ListView {
                anchors.fill:parent
                orientation: ListView.Horizontal
                spacing: 5
                model: 8
                clip: true
                delegate: WeatherCard {}
                snapMode: ListView.SnapToItem

                Component.onCompleted: positionViewAtIndex(Math.floor(Time.hours/3), ListView.Beginning)
            }
        }
    }
    component WeatherCard: Rectangle{
        id: root

        required property int index

        property var hourly: Weather.weather.weather[0].hourly[index]

        implicitHeight: parent.height
        implicitWidth: (hourlyw.width-15)/4
        Layout.fillWidth:true

        color:Color.surface_container
        radius:10

        Item {
            anchors.fill:parent
            anchors.margins:5

            Column {
                StyledText {
                    text: root.hourly.time / 100 + " Hour"
                }
                MaterialIcon {
                    icon: Weather.getIcon(root.hourly.weatherCode)
                    font.pixelSize:16
                }
                StyledText {
                    text: ` : ${root.hourly.tempC}°C (${root.hourly.FeelsLikeC}°C)`
                    surface:3
                    font.pixelSize:10
                }
                StyledText {
                    text: ` : ${root.hourly.precipMM}mm`
                    surface:3
                    font.pixelSize:10
                }
            }
        }
    }
}
