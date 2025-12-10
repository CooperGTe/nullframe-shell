import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell
import qs.services
import qs.modules.common

WlSessionLockSurface {
    id: root
    required property LockContext context
    readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition
    function formatTime(val) {
        var totalSec = Math.floor(val);

        var min = Math.floor(totalSec / 60);
        var sec = totalSec % 60;

        return ("0" + min).slice(-2) + "." + ("0" + sec).slice(-2);
    }
    function time(sec) {
        var h = Math.floor(sec / 3600);
        var m = Math.floor((sec % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    property bool startAnim: false
    property bool exiting: false
    color:"transparent"

    Connections {
        target: context
        function onUnlocked() {
            startAnim = false;
        }
    }
    Component.onCompleted: {
        startAnim = true;

        //passwordBox.forceActiveFocus();
    }

    Image { //image fallback
        anchors.fill: parent
        source: Quickshell.shellDir + "assets/bg-placeholder.png"
        sourceSize.width: 1366
        sourceSize.height: 768
        fillMode: Image.PreserveAspectCrop
        mipmap:true
        smooth:true
        cache:true
        layer.effect: MultiEffect {
            contrast: 0.05
            brightness: -0.2
            saturation: 0.1
        }
        scale: root.startAnim ? 1.1 : 1
        Behavior on scale {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            }
        }
        opacity: root.startAnim ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            }
        }
    }
    ScreencopyView {
        id: background
        anchors.fill: parent
        captureSource: root.screen
        live: false
        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: root.startAnim ? 1 : 0

            blurMax: 64
            contrast: 0.05
            saturation: 0.1
            Behavior on blur {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                autoPaddingEnabled: false
                blurEnabled: true
                blur: root.startAnim ? 1 : 0

                blurMax: 32
                Behavior on blur {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
                    }
                }
            }
        }
        scale: root.startAnim ? 1.1 : 1
        Behavior on scale {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            }
        }
    }
    Item {
        anchors.fill: parent
        opacity: root.startAnim ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            }
        }

        
        ColumnLayout {
            // Uncommenting this will make the password entry invisible except on the active monitor.
            // visible: Window.active

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin:60
            }
            Rectangle {
                implicitHeight:100
                implicitWidth: 300
                color: "#080812"
                radius: 20
                ColumnLayout {
                    anchors.centerIn:parent
                    spacing:-20
                    Text {
                        text: Time.format("hh:mm:ss")
                        color: "#dfdfff"
                        font.pixelSize:50
                        font.family: "monospace"
                        font.bold:true
                    }
                    Text {
                        text: Time.format("yyyy年MM月dd日")
                        color: "#afafbf"
                        font.pixelSize:12
                        font.family: "monospace"
                        Layout.margins:5
                    }
                }
            }
            RowLayout{
                Rectangle {
                    Layout.fillWidth:true
                    implicitHeight:60
                    color:"#080812"
                    radius:20
                    RowLayout {
                        anchors.fill:parent
                        ClippingRectangle {
                            implicitWidth:50
                            implicitHeight:50
                            Layout.alignment:Qt.AlignVCenter
                            Layout.margins:5
                            radius:15
                            clip: true
                            color: "#12131F"
                            Image {
                                anchors.fill: parent
                                source: Quickshell.shellDir + "/assets/profile.png"
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 256
                                sourceSize.height: 256
                                asynchronous: true
                                mipmap:true
                                smooth:true
                                cache: true
                            }
                        }
                        ColumnLayout {
                            Layout.alignment:Qt.AlignLeft
                            spacing:0

                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text: Quickshell.env('USER')
                                color: "#dfdfff"
                                font.bold:true
                                font.family:"monospace"
                                font.pixelSize:16
                            }
                            Text {
                                Layout.fillWidth:true
                                Layout.alignment: Qt.AlignLeft
                                text: "Uptime: " + root.time(System.uptime)
                                color: "#dfdfff"
                                font.pixelSize:10
                            }
                        }            
                    }
                }
                Rectangle {
                    color:"#080812"
                    radius:20
                    implicitHeight:60
                    implicitWidth:60
                    ClippedFilledCircularProgress {
                        size: 50
                        anchors.centerIn:parent
                        value: Battery.percentage
                        colPrimary: "#DFDFFF"
                        colSecondary: "#12131F"
                        lineWidth: 5
                        Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                fill: 1
                                icon: Battery.isCharging ? "bolt" : "battery_android_5"

                                font.pixelSize: 24
                                color: "#DFDFFF"
                            }
                        }
                    }
                }
            }
            Rectangle {
                implicitWidth: 300
                implicitHeight:45
                color: "#080812"
                radius:20
                RowLayout {
                    anchors.verticalCenter:parent.verticalCenter
                    anchors.fill:parent
                    TextField {
                        id: passwordBox

                        Layout.leftMargin:5
                        Layout.fillWidth:true
                        padding: 10
                        background: Rectangle{
                            color: "#12131F"
                            radius:15
                        }
                        placeholderText: qsTr("Enter Password")

                        focus: true
                        enabled: !root.context.unlockInProgress
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData

                        // Update the text in the context when the text in the box changes.
                        onTextChanged: root.context.currentText = this.text;

                        // Try to unlock when enter is pressed.
                        onAccepted: root.context.tryUnlock();

                        // Update the text in the box to match the text in the context.
                        // This makes sure multiple monitors have the same text.
                        Connections {
                            target: root.context

                            function onCurrentTextChanged() {
                                passwordBox.text = root.context.currentText;
                            }
                        }
                    }

                    Button {
                        text: "Unlock"
                        padding: 10
                        Layout.rightMargin:5

                        // don't steal focus from the text box
                        focusPolicy: Qt.NoFocus

                        enabled: !root.context.unlockInProgress && root.context.currentText !== "";
                        onClicked: root.context.tryUnlock();
                        background: Rectangle{
                            color: "#12131F"
                            radius:15
                        }
                    }
                }

                Label {
                    visible: root.context.showFailure
                    text: "Incorrect password"
                }
            }
            ClippingRectangle {
                color: "#080812"
                radius:20
                implicitHeight: 90
                Layout.fillWidth: true
                RowLayout {
                    anchors.fill: parent
                    ClippingRectangle {
                        implicitWidth:80
                        implicitHeight:80
                        Layout.leftMargin:5
                        radius:17
                        clip: true
                        color: "black"
                        Image {
                            anchors.fill: parent
                            source: root.activePlayer?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            cache: true
                        }
                    }
                    ColumnLayout{
                        Layout.rightMargin:10
                        Text{
                            Layout.alignment:Qt.AlignBottom
                            text:root.activePlayer.trackTitle ?? ""
                            elide: Text.ElideRight
                            Layout.maximumWidth: 190
                            font.pixelSize: 12
                            color:"#DFDFFF"
                            font.bold:true
                        }
                        Text{
                            Layout.alignment:Qt.AlignTop
                            text:root.activePlayer.trackArtist ?? ""
                            Layout.maximumWidth: 140
                            Layout.topMargin: -5
                            font.pixelSize: 10
                            color:"#8F8F9F"
                        }
                        RowLayout {
                            spacing: 5
                            Layout.fillWidth:true
                            Layout.alignment:Qt.AlignHCenter
                            Button {
                                Layout.alignment: Qt.AlignLeft
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                background: Rectangle { 
                                    color: "#12131F" 
                                    radius:10
                                }
                                onClicked: activePlayer.previous()
                                contentItem: Item {
                                    anchors.fill: parent
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: "repeat_one"
                                        font.pixelSize: 20
                                        color: "#DFDFFF"
                                        fill: 1
                                    }
                                }
                            }                        
                            //spacer
                            Item {
                                Layout.fillWidth:true
                            }
                            Button {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                background: Rectangle { 
                                    color: "#12131F" 
                                    radius:10
                                }
                                contentItem: Item {
                                    anchors.fill: parent
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: "skip_previous"
                                        font.pixelSize: 20
                                        color: "#DFDFFF"
                                        fill: parent.hovered ? 1 : 0
                                    }
                                    property bool hovered: false
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.hovered = true
                                        onExited: parent.hovered = false
                                        onClicked: activePlayer.previous()
                                    }
                                }
                            }           
                            Button {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                background: Rectangle { 
                                    color: "#dfdfdf" 
                                    radius:20
                                    anchors.fill:parent
                                }

                                contentItem: Item {
                                    anchors.fill: parent
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                                        font.pixelSize: 20
                                        fill: 1
                                        color: "#22232F"
                                    }
                                    property bool hovered: false
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.hovered = true
                                        onExited: parent.hovered = false
                                        onClicked: activePlayer.togglePlaying();
                                    }
                                }
                                WheelHandler {
                                    target: null
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    onWheel: (event) => {
                                        if (event.angleDelta.y < 0)
                                        activePlayer.volume -= 0.02
                                        else if (event.angleDelta.y > 0)
                                        activePlayer.volume += 0.02
                                    }
                                }
                            }
                            Button {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                background: Rectangle { 
                                    color: "#12131F" 
                                    radius:10
                                }
                                padding: 0

                                contentItem: Item {
                                    anchors.fill: parent
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: "skip_next"
                                        font.pixelSize: 20
                                        fill: parent.hovered ? 1 : 0
                                        color: "#DFDFFF"
                                    }
                                    property bool hovered: false
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.hovered = true
                                        onExited: parent.hovered = false
                                        onClicked: activePlayer.next()
                                    }
                                }
                            }
                            //spacer
                            Item {
                                Layout.fillWidth:true
                            }
                            Button {
                                Layout.alignment: Qt.AlignRight
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                background: Rectangle { 
                                    color: "#12131F" 
                                    radius:10
                                }
                                onClicked: activePlayer.previous()
                                contentItem: Item {
                                    anchors.fill: parent
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: "shuffle"
                                        font.pixelSize: 20
                                        color: "#DFDFFF"
                                        fill: 1
                                    }
                                }
                            }                        
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin:-5
                            spacing:5
                            Text {
                                text: root.formatTime(root.position)
                                color:"#dfdfdf"
                            }
                            Slider {
                                // Stretches to fill all left-over space
                                Layout.fillWidth: true
                                Layout.alignment:Qt.AlignVCenter

                                implicitHeight: 10
                                value: root.position / activePlayer.length
                                onMoved: {
                                    activePlayer.position = this.value * activePlayer.length
                                    MprisController.visualPosition = this.value * activePlayer.length
                                }
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
                                        color: "#DFDFFF"

                                        implicitWidth: parent.width * (root.position / activePlayer.length)
                                        radius: 20
                                    }
                                    Rectangle {
                                        anchors {
                                            top: parent.top
                                            bottom: parent.bottom
                                            right: parent.right
                                        }
                                        color: "#12131F"

                                        implicitWidth: parent.width * (1 - (root.position / activePlayer.length)) - 1
                                        radius: 20
                                    }
                                }
                                WheelHandler {
                                    target: null
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    onWheel: (event) => {
                                        if (event.angleDelta.y < 0) {
                                            activePlayer.seek(-5) 
                                            MprisController.visualPosition -= 5
                                        }
                                        else if (event.angleDelta.y > 0) {
                                            activePlayer.seek(+5) 
                                            MprisController.visualPosition += 5
                                        }
                                    }
                                }
                            }
                            Text {
                                text: root.formatTime(activePlayer.length)
                                color:"#dfdfdf"
                            }
                        }
                    }
                }
            }
        }
    }
}
