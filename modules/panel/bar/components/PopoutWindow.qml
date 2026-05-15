import QtQuick
import Quickshell

import qs.config

PopupWindow {
    id:root

    required property var parent
    required property bool visibility

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

    anchor.edges: Config.bar.position === 0 ? Edges.Left
    : (Config.bar.position === 1 ? Edges.Top 
    : (Config.bar.position === 2 ? Edges.Right
    : Edges.Bottom))

    anchor.gravity: Config.bar.position === 0 ? Edges.Right
    : (Config.bar.position === 1 ? Edges.Bottom 
    : (Config.bar.position === 2 ? Edges.Left
    : Edges.Top))    

    anchor.margins{
        left: (Config.bar.position === 0) ? Config.barTotalWidth : 0
        top: (Config.bar.position === 1) ? Config.barTotalWidth : 0
        right: (Config.bar.position === 2) ? Config.barTotalWidth : 0
        bottom: (Config.bar.position === 3) ? Config.barTotalWidth : 0
    }

    visible: false
    color:"transparent"
}

