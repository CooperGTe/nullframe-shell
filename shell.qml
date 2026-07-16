//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma IconTheme Papirus-Dark

import Quickshell
import qs.modules.panel
import qs.modules.popups.osd
import qs.modules.desktopWidget
import qs.modules.notificationPopup
import qs.modules.lockscreen
import qs.modules.lyricsEngine

ShellRoot {
    Panel {}
    LyricsEngine {}
    OSD {}
    OSDKeyboard {}
    DesktopWidget {}
    Notification{}
    LockScreen{}
    //Background{}
    //Overview{}
}
