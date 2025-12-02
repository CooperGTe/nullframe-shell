//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1

import Quickshell
import qs.modules.bar
import qs.modules.lyricsEngine
import qs.modules.osd
import qs.modules.desktopWidget
import qs.modules.notificationPopup
import qs.modules.sidepanel
import qs.modules.lockscreen

ShellRoot {
    SidePanel{}
    Bar {}
    LyricsEngine {}
    OSD {}
    OSDKeyboard {}
    DesktopWidget {}
    Notification{}
    //LockScreen{}
}

