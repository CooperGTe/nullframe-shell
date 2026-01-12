pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.config

//
// Boilerplate by mas <3
//

PanelWindow {
	id: root
    WlrLayershell.namespace: "notification"

	readonly property var notificationCount: notifications.length
	property list<QtObject> notifications: []
	property NotificationServer server: NotificationServer {
		actionIconsSupported: true
		actionsSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		bodySupported: true
		imageSupported: true
		persistenceSupported: true
		onNotification: function (notification) {
			notification.tracked = true;
			root.notifications.push(notification);
		}
	}

	function removePopupNotification(notification) {
		var newList = [];
		for (var i = 0; i < root.notifications.length; i++)
			if (root.notifications[i] !== notification)
				newList.push(root.notifications[i]);

		root.notifications = newList;
	}

	function dismissAll() {
		for (var i = 0; i < root.notifications.length; i++)
			root.notifications[i].dismiss();

		root.notifications = [];
	}

	anchors {
		top: true
		right: true
	}

	exclusiveZone: 0
	color: "transparent"

	implicitWidth: 300
	implicitHeight: 728

    
	visible: root.notifications.length > 0 ? true : false

    component Anim: NumberAnimation { 
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }

    mask: Region {
        id:mask
        width: root.width
        height: listView.contentHeight
    }


	ListView {
		id: listView

		anchors.right: parent.right
		anchors.top: parent.top
		anchors.fill: parent

		spacing: 5
		clip: true
        addDisplaced: Transition {
            NumberAnimation {
                property: "y" // Animates the vertical position
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        removeDisplaced: Transition {
            NumberAnimation {
                property: "y" // Animates the vertical position
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

		model: ScriptModel {
			values: [...root.notifications.map(a => a)]
		}

		delegate: Flickable {
			id: delegateFlick

			required property Notification modelData

			implicitWidth: listView.width
			implicitHeight: contentLayout.implicitHeight + 24
			boundsBehavior: Flickable.DragAndOvershootBounds
			flickableDirection: Flickable.HorizontalFlick

			RetainableLock {
				id: retainNotif

				object: delegateFlick.modelData
				locked: true
			}
            Timer {
                id:lifetime
                interval: (modelData.expireTimeout && modelData.expireTimeout > 0) ? modelData.expireTimeout : 5000
                running: true
                repeat: false
                onTriggered: {
                    tAnim = true
                    lifetimeafter.start()
                }
            }
            Timer {
                id:lifetimeafter
                interval: 700
                running: false
                repeat: false
                onTriggered: {
                    delegateFlick.modelData.closed("Expired")
                    anim = false
                    tAnim = false
                    deleteBeforeAnim.start()
                }
            }
            Timer {
                id:deleteBeforeAnim
                interval: 500
                repeat:false
                running:false
                onTriggered: {
                    root.removePopupNotification(delegateFlick.modelData)
                }
            }
            property bool anim: false
            property bool tAnim: false
            Timer {
                interval: 200
                running:true
                repeat:false
                onTriggered: {
                    anim = true
                    tAnim = true
                    deleteT.start()
                }
            }
            Timer {
                id:deleteT
                interval: 700
                repeat:false
                running:false
                onTriggered: {
                    tAnim = false
                }
            }
            Item {
                Component.onCompleted: {
                    parent.layer.enabled = true;
                    parent.layer.effect = effectComponent;
                }

                Component {
                    id: effectComponent
                    MultiEffect {
                        shadowEnabled: true
                        shadowOpacity: 1
                        shadowColor: "black"
                        shadowBlur: 1
                        shadowScale: 1
                    }
                }
            }

            Rectangle {
                id:notifItem
				anchors.fill: parent
				color: Color.base
				radius: 15
                anchors.margins: 5
                anchors.rightMargin: anim ? 5 : -300
                anchors.leftMargin: anim ? 20 : 305
                Behavior on anchors.rightMargin {
                    Anim{}
                }
                Behavior on anchors.leftMargin {
                    Anim{}
                }
                RowLayout {
                    spacing:0
                    anchors.fill:parent
                    Rectangle {
                        implicitHeight:60
                        implicitWidth:60
                        Layout.leftMargin:12
                        color:"transparent"
                        visible: (delegateFlick.modelData.appIcon !== "") || (delegateFlick.modelData.image !== "")

                        Image {
                            anchors.fill: parent
                            source: delegateFlick.modelData.image || Quickshell.iconPath(delegateFlick.modelData.appIcon, "image-missing")
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    ColumnLayout {
                        id: contentLayout
                        Layout.margins: 5
                        Layout.fillWidth:true
                        Layout.fillHeight:true
                        RowLayout {
                            

                            Text {
                                id: appName

                                Layout.fillWidth: true
                                text: delegateFlick.modelData.appName
                                font.pixelSize: 16
                                font.weight: Font.Medium
                                color: Color.surface
                                elide: Text.ElideRight
                            }

                            Button {
                                text: "✕"
                                onClicked: {
                                    delegateFlick.modelData.dismiss()
                                    anim = false
                                    deleteBeforeAnim.start()
                                }
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                background: Rectangle { 
                                    color: Color.container 
                                    radius: 24
                                }
                            }
                        }

                        Text {
                            id: summary

                            Layout.fillWidth: true
                            text: delegateFlick.modelData.summary
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Color.surface
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                        }
                        Text {
                            id: body

                            Layout.fillWidth: true
                            text: delegateFlick.modelData.body
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Color.surface
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                        }
                        
                        RowLayout {
                            spacing:5
                            Layout.fillWidth:true
                            Repeater {
                                model: delegateFlick.modelData.actions
                                Button {
                                    required property NotificationAction modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 24
                                    text: modelData?.text
                                    onClicked:{ modelData.invoke();
                                        //hack dismiss fuck yeah
                                        anim = false
                                        deleteBeforeAnim.start()
                                        lifetime.stop()
                                    }
                                    background: Rectangle { 
                                        color: Color.container 
                                        radius: 24
                                    }
                                }
                            }
                        }
                    }
				}
			}
            Rectangle {
                id:transitionItem
				anchors.fill: parent
				color: Color.surface
				radius: 0
                anchors.margins: 0
                anchors.leftMargin: tAnim ? 20 : 305
                Behavior on anchors.leftMargin {
                    Anim{}
                }
            }
		}
	}
}
