#!/bin/bash

if echo 3 | pkexec tee /proc/sys/vm/drop_caches >/dev/null 2>&1; then
    action=$(notify-send -A "yes=ありがと" -a "Resources Manager" -i "$HOME/Dotfiles/moonlightshell/assets/asset3.png" "Cache has been dropped" "nom nom yum")
    if [[ $action == "yes" ]]; then
        notify-send -i "$HOME/Dotfiles/moonlightshell/assets/asset2.png" -a "Resources Manager" "no problem"
    fi
else
    notify-send "sorry, i don't have your key" -a "Resources Manager" -i "$HOME/Dotfiles/moonlightshell/assets/asset2.png"
fi
