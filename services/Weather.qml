pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.services
import qs.config

Singleton {
    id:root

    property alias weather: json.data
    property alias lastUpdateHour: json.lastUpdateHour
    property alias lastUpdateTime: json.lastUpdateTime

    property var currentCondition: root.weather.current_condition[0]
    property string icon: getIcon(weather.current_condition[0].weatherCode)
    property string weatherDesc: root.currentCondition.weatherDesc[0].value

    property string tempC: root.currentCondition.tempC
    property string feelsLikeC: root.currentCondition.feelsLikeC
    property string humidity: root.currentCondition.humidity

    property string pressure: root.currentCondition.pressure
    property string uvIndex: root.currentCondition.uvIndex
    property string visibility: root.currentCondition.visibility

    property string windspeedKmph: root.currentCondition.windspeedKmph
    property string winddirDegree: root.currentCondition.winddirDegree
    property string winddir16Point: root.currentCondition.winddir16Point


    function fetch(check: bool) {
        console.log(`${root.lastUpdateHour} | ${Time.hours} | ${(Time.hours != root.lastUpdateHour)}`)
        if (check) {
            if (Time.hours != root.lastUpdateHour) fetch.running = true
        } else fetch.running = true
        
    }

    FileView {
        id: cache
        path: Quickshell.cacheDir + "/weather_cache.json"

        preload: true

        onLoaded: {
            root.fetch(true)
        }
        // when changes are made to properties in the adapter, save them
        onAdapterUpdated: writeAdapter()
        onLoadFailed: err => {
            if (err == FileViewError.FileNotFound) {
                writeAdapter();
                console.log("file not found")
            }
        }

        JsonAdapter {
            id:json

            property var data: null
            property int lastUpdateHour: 0
            property string lastUpdateTime: ""
        }
    }

    Process {
        id: fetch
        running: false
        command: ["curl", "-s", "https://wttr.in/" + Config.weatherLocationName.replace(" ", "+") + "?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                console.log(`Weather Fetch: ${fetch.command}`)
                json.data = JSON.parse(this.text)
                json.lastUpdateHour = Time.hours
                json.lastUpdateTime = Time.format("hh:mm:ss")
            }
        }
    }
    
    Timer {
        id: autorefresh
        running: true
        interval: 3600000
        repeat: true
        onTriggered: root.fetch(true)
    }
    

    function getIcon(code: string): string {
        const WEATHER_ICON_MAP = {
            // Clear / Sunny
            113: "sunny",

            // Cloudy
            116: "partly_cloudy_day",
            119: "cloudy",
            122: "cloudy",

            // Haze / Dust / Smoke / Smog (no dedicated Material Symbols weather icons; "foggy"/"air" are closest)
            125: "foggy",       // Haze
            128: "air",         // Dust haze
            131: "air",         // Blowing dust
            134: "air",         // Dust storm
            137: "air",         // Sandstorm
            140: "air",         // Severe sandstorm
            146: "foggy",       // Smoke
            149: "foggy",       // Smoky haze
            152: "foggy",       // Smog
            155: "foggy",       // Severe smog
            158: "air",         // Saharan dust
            161: "air",         // Dust

            // Fog / Mist
            143: "mist",        // Mist
            248: "foggy",       // Fog
            260: "foggy",       // Freezing fog

            // Drizzle
            176: "rainy_light",
            185: "rainy_light",
            263: "rainy_light",
            266: "rainy_light",
            281: "rainy_light",
            284: "rainy_light",

            // Rain
            293: "rainy",
            296: "rainy",
            299: "rainy",
            302: "rainy",
            305: "rainy",
            308: "rainy_heavy",
            311: "rainy",
            314: "rainy_heavy",
            353: "rainy",
            356: "rainy_heavy",
            359: "rainy_heavy",

            // Sleet
            179: "rainy_snow",
            182: "rainy_snow",
            317: "rainy_snow",
            320: "rainy_snow",
            362: "rainy_snow",
            365: "rainy_snow",

            // Snow
            323: "weather_snowy",
            326: "weather_snowy",
            329: "weather_snowy",
            332: "weather_snowy",
            335: "snowing_heavy",
            338: "snowing_heavy",
            368: "weather_snowy",
            371: "snowing_heavy",
            227: "snowing_heavy", // blowing snow
            230: "snowing_heavy", // blizzard

            // Ice pellets
            350: "weather_hail",
            374: "weather_hail",
            377: "weather_hail",

            // Thunder
            200: "thunderstorm",
            386: "thunderstorm",
            389: "thunderstorm",
            392: "thunderstorm",
            395: "thunderstorm",
        }
        return WEATHER_ICON_MAP[Number(code)] || "Unknown"
    }
}
