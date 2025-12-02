pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

Scope {
  id: scope

  property real scaleFactor: 0.2
  property real borderWidth: 0
  property bool wallpaperEnabled: true
  property bool iconsEnabled: true
  property string wallpaperPath: "/home/katsuro/Dotfiles/wallpaper/Favorites/Starred Night.png"

  GlobalShortcut {
    name: "overview"
    onPressed: lazyloader.active = !lazyloader.active
  }

  Connections {
    target: Hyprland

    function onRawEvent() {
      Hyprland.refreshMonitors();
      Hyprland.refreshWorkspaces();
      Hyprland.refreshToplevels();
    }
  }

  LazyLoader {
    id: lazyloader
    active: false

    PanelWindow {
      id: root

      property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
      property real workspaceWidth: (root.monitor.width - (root.reserved[0] + root.reserved[2])) * scope.scaleFactor
      property real workspaceHeight: (root.monitor.height - (root.reserved[1] + root.reserved[3])) * scope.scaleFactor
      property real containerWidth: workspaceWidth + scope.borderWidth * 2
      property real containerHeight: workspaceHeight + scope.borderWidth * 2
      property list<int> reserved: monitor.lastIpcObject?.reserved
      

      implicitWidth: contentGrid.implicitWidth + 12
      implicitHeight: contentGrid.implicitHeight + 12

      color: "transparent"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

      // Base Background
      Rectangle {
        color: "#151515"
        anchors.fill: parent
        anchors.margins: -12
      }

      // Overlay Layer
      Rectangle {
        id: overLayer
        color: "transparent"
        z: 1
        anchors.fill: parent
      }

      // Workspaces Grid
      GridLayout {
        id: contentGrid
        rows: 2
        columns: 4
        rowSpacing: 12
        columnSpacing: 12
        anchors.centerIn: parent

        // Workspaces Containers
        Repeater {
          model: 8

          delegate: Rectangle {
            id: workspaceContainer

            required property int index
            property HyprlandWorkspace workspace: Hyprland.workspaces.values.find(w => w.id === index + 1) ?? null
            property bool hasFullscreen: !!(workspace?.toplevels?.values.some(t => t.wayland?.fullscreen))
            property bool hasMaximized: !!(workspace?.toplevels?.values.some(t => t.wayland?.maximized))

            implicitWidth: root.containerWidth
            implicitHeight: root.containerHeight

            color: "#2d4f68"
            border.width: 2
            border.color: hasMaximized ? "red" : workspace?.focused ? "#50a4e7" : "#252525"
            clip: true

            Loader {
              active: scope.wallpaperEnabled
              visible: active
              anchors.centerIn: parent

              sourceComponent: Image {
                source: scope.wallpaperPath
                sourceSize.width: root.workspaceWidth
                width: root.workspaceWidth
                height: root.workspaceHeight
                fillMode: Image.PreserveAspectCrop
                smooth: false
                cache: true
              }
            }

            // Toplevel DropArea
            DropArea {
              anchors.fill: parent

              onEntered: drag => drag.source.isCaught = true
              onExited: drag.source.isCaught = false

              onDropped: drag => {
                const toplevel = drag.source;

                if (toplevel.modelData.workspace !== workspaceContainer.workspace) {
                  const address = toplevel.modelData.address;

                  Hyprland.dispatch(`movetoworkspacesilent ${workspaceContainer.index + 1}, address:0x${address}`);
                  Hyprland.dispatch(`movewindowpixel exact ${toplevel.initX} ${toplevel.initY}, address:0x${address}`);
                }
              }
            }

            MouseArea {
              anchors.fill: parent
              onClicked: {
    if (workspaceContainer.workspace !== Hyprland.focusedWorkspace)
        Hyprland.dispatch(`workspace ${parent.index + 1}`)
    lazyloader.active = !lazyloader.active
}            }

            // Toplevels
            Repeater {
              model: parent.workspace?.toplevels

              delegate: ScreencopyView {
                id: toplevel

                required property HyprlandToplevel modelData
                property Toplevel waylandHandle: modelData?.wayland
                property var toplevelData: modelData.lastIpcObject
                property int initX: toplevelData.at?.[0] ?? 0
                property int initY: toplevelData.at?.[1] ?? 0
                property Rectangle originalParent: workspaceContainer
                property Rectangle visualParent: overLayer
                property bool isCaught: false

                captureSource: waylandHandle
                live: true

                width: sourceSize.width * scope.scaleFactor
                height: sourceSize.height * scope.scaleFactor
                scale: (Drag.active && !toplevelData?.floating) ? 0.75 : 1

                x: (toplevelData?.at?.[0] - (waylandHandle?.fullscreen ? 0 : root.reserved[0])) * scope.scaleFactor + scope.borderWidth
                y: (toplevelData?.at?.[1] - (waylandHandle?.fullscreen ? 0 : root.reserved[1])) * scope.scaleFactor + scope.borderWidth
                z: (waylandHandle?.fullscreen || waylandHandle?.maximized) ? 2 : toplevelData?.floating ? 1 : 0

                Drag.active: mouseArea.drag.active
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2
                Drag.onActiveChanged: {
                  if (Drag.active) {
                    parent = visualParent;
                  } else {
                    var mapped = mapToItem(originalParent, 0, 0);
                    parent = originalParent;

                    // fix this ugly shit
                    if (toplevelData?.floating) {
                      x = mapped.x;
                      y = mapped.y;
                    } else if (!toplevelData?.floating) {
                      x = !isCaught ? mapped.x : (toplevelData?.at?.[0] - (waylandHandle?.fullscreen ? 0 : root.reserved[0])) * scope.scaleFactor + scope.borderWidth;
                      y = !isCaught ? mapped.y : (toplevelData?.at?.[1] - (waylandHandle?.fullscreen ? 0 : root.reserved[1])) * scope.scaleFactor + scope.borderWidth;
                    }
                  }
                }

                Behavior on scale {
                  NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutCubic
                  }
                }

                IconImage {
                  source: Quickshell.iconPath(DesktopEntries.heuristicLookup(toplevel.waylandHandle?.appId)?.icon, "image-missing")
                  implicitSize: 48
                  backer.cache: true
                  backer.asynchronous: true
                  anchors.centerIn: parent
                }

                MouseArea {
                  id: mouseArea
                  property bool dragged: false

                  drag.target: (toplevel.waylandHandle?.fullscreen || toplevel.waylandHandle?.maximized) ? undefined : toplevel
                  acceptedButtons: Qt.LeftButton | Qt.RightButton
                  anchors.fill: parent

                  onPressed: {
                    dragged = false;
                  }

                  onPositionChanged: {
                    if (drag.active)
                      dragged = true;
                  }

                  onClicked: mouse => {
                    if (!dragged) {
                      if (mouse.button === Qt.LeftButton) {
                        toplevel.waylandHandle.activate();
                        //close overview
                        lazyloader.active = !lazyloader.active
                      } else if (mouse.button === Qt.RightButton)
                        toplevel.waylandHandle.close();
                    }
                  }

                  onReleased: {
                    if (dragged && !(toplevel.waylandHandle?.fullscreen || toplevel.waylandHandle?.maximized)) {
                      const mapped = toplevel.mapToItem(toplevel.originalParent, 0, 0);
                      const x = Math.round(mapped.x / scope.scaleFactor + root.reserved[0]);
                      const y = Math.round(mapped.y / scope.scaleFactor + root.reserved[1]);

                      Hyprland.dispatch(`movewindowpixel exact ${x} ${y}, address:0x${toplevel.modelData.address}`);
                      toplevel.Drag.drop();
                    }
                  }
                }
              }
            }

            // Workspace Id
            Text {
              text: parent.index + 1
              x: 8
              z: 2
              anchors.bottom: parent.bottom
            }
          }
        }
      }
    }
  }
}
