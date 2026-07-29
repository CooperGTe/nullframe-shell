// Global variable template
// do not change directly, use Global.get(screen).var instead
import QtQuick

QtObject {
    // Comment us to draw binding relation from write -> read
    // ---
    // Launcher -> LyricsEngine
    property bool hideLyrics: false
    // Dock -> LyricsEngine
    property bool panelHovered: false

    // Panel, Dock -> Launcher, Panel
    property bool launcherVisibility: false
    // Panel, Launcher -> Dock
    property bool dockHoverBlocker: false
}
