//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma IconTheme Papirus-Dark

import Quickshell
import qs.modules.bar
import qs.modules.panel
import qs.modules.lyricsEngine
import qs.modules.osd
import qs.modules.desktopWidget
import qs.modules.notificationPopup
import qs.modules.lockscreen
import qs.modules.dock
//import qs.modules.overview
//import qs.modules.background

ShellRoot {
    Panel {}
    LyricsEngine {}
    OSD {}
    OSDKeyboard {}
    DesktopWidget {}
    Notification{}
    LockScreen{}
    Dock{}
    //Background{}
    //Overview{}
}
