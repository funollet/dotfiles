#!/bin/bash
# toggle-window.sh

# $ wmctrl -l -x
# 0x01c00004 -1 pcmanfm-qt.pcmanfm-qt        N/A pcmanfm-qt
# 0x01a00006 -1 lxqt-panel.lxqt-panel        N/A LxQt Panel
# 0x02800003  1 gvim.Gvim             jfunollet wp.py (~/code/dexma/infrastructure/fabfile) - GVIM
# 0x02c00016  1 konsole.Konsole       jfunollet infrastructure : bash – Konsole
# 0x040005e4  1 Pidgin.Pidgin         jfunollet Some Contact
# 0x04000064  1 Pidgin.Pidgin         jfunollet Buddy List



toggle_pidgin_buddy_list () {
    set_visible=1
    wmctrl -l -x | grep -q 'Buddy List' && set_visible=0
    qdbus im.pidgin.purple.PurpleService /im/pidgin/purple/PurpleObject \
        im.pidgin.purple.PurpleInterface.PurpleBlistSetVisible "${set_visible}"
}


toggle_pidgin_conversation () {
    win_id=$(wmctrl -l -x | awk '! /Buddy List/ && /Pidgin.Pidgin/ {print $1}')
    wmctrl -i -r "${win_id}" -b toggle,hidden
}

toggle_hipchat () {
    wmctrl -l | grep -q HipChat
    if [ $? == 0 ] ; then wmctrl -F -c HipChat              # close window
    else hipchat > /dev/null                                # activate existing instance or run new instance
    fi
}



toggle_app () {
    # Moves app window to/from last desktop.
    #
    # $1: name of the app as show by 'wmctrl -l'.
    #
    local app current_desktop last_desktop

    app=$1
    last_desktop=$(wmctrl -d | tail -1 | awk '{print $1}')
    current_desktop=$(wmctrl -d | awk '/\*/ {print $1}')
    app_in_desktop=$(wmctrl -x -l | awk "/$app/ {print \$2}")

    ## Uncomment to debug.
    # echo "app            : " $app
    # echo "last_desktop   : " $last_desktop
    # echo "current_desktop: " $current_desktop
    # echo "app_in_desktop : " $app_in_desktop

    if [[ $app_in_desktop == $current_desktop ]] ; then
      wmctrl -x -r ${app} -t $last_desktop     # move app to last desktop
    else
      wmctrl -x -R ${app}                      # move app here, raise, focus 
    fi
}


__toggle_telegram () {
    wmctrl -l | grep -q 'Telegram'
    if [ $? == 0 ] ; then wmctrl -F -c 'Telegram'           # close window
    else flatpak run org.telegram.desktop > /dev/null 2>&1  # activate existing instance or run new instance
    fi
}


__toggle_discord () {
    wmctrl -l | grep -q ' Discord'
    if [ $? == 0 ] ; then wmctrl -c 'Discord'                 # close window
    else flatpak run com.discordapp.Discord > /dev/null 2>&1  # activate existing instance or run new instance
    fi
}


case $1 in
    telegram|Telegram)
        toggle_app telegram
        ;;
    discord|Discord)
        toggle_app discord
        ;;
    # slack|Slack)
    #     toggle_app slack.Slack
    #     ;;
    # pidgin_buddy_list|pidgin_conversation|hipchat)
    #     "toggle_$1"
    #     ;;
    *)
        exit 1
        ;;
esac



# __toggle_slack () {
#     wmctrl -l | grep -q 'Slack - '
#     if [ $? == 0 ] ; then wmctrl -F -c 'Slack - '  # close window
#     else /usr/bin/slack > /dev/null 2>&1                    # activate existing instance or run new instance
#     fi
# }
# 
