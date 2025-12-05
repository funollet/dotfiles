import re
import subprocess
from pathlib import Path
import asyncio


from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import DropDown
from libqtile.config import EzClick as Click
from libqtile.config import EzDrag as Drag
from libqtile.config import EzKey as Key
from libqtile.config import EzKeyChord as KeyChord
from libqtile.config import Group, Match, ScratchPad, Screen
from libqtile.lazy import lazy
from libqtile.log_utils import logger
from time import sleep

mod = "mod4"
# terminal = guess_terminal()
terminal = "ghostty"

colors = {
    "white": "#ffffff",
    "red": "ff0000",
    "yellow": "c18f41",
    "grey": "404040",
}


def _get_next_screen(qtile):
    """Get the next screen in the list of screens. Wraps around.

    Args:
        qtile: The qtile object.

    Returns:
        The next screen in the list of screens.
    """
    current_screen_idx = qtile.screens.index(qtile.current_screen)
    if current_screen_idx + 1 != len(qtile.screens):
        return qtile.screens[current_screen_idx + 1]
    else:  # wrap around if it's the last screen
        return qtile.screens[0]


def window_to_next_screen(qtile, switch_group=False, switch_screen=False):
    """Move the current window to the next screen. Wraps around.

    Args:
        qtile: The qtile object.
        switch_group: If True, switch to the group of the destination screen.
        switch_screen: If True, switch to the destination screen.
    """
    next_screen = _get_next_screen(qtile)

    # Move the current window to the destination screen's group
    qtile.current_window.togroup(next_screen.group.name, switch_group=switch_group)

    # If switch_screen is True, switch focus to the destination screen
    if switch_screen:
        qtile.to_screen(next_screen.index)


@lazy.function
def prev_group_or_stay(qtile):
    """Switch to the previous group. Not wrap around."""
    current_index = qtile.groups.index(qtile.current_group)
    if current_index > 0:
        qtile.current_screen.prev_group(skip_empty=True)


@lazy.function
def next_group_or_stay(qtile):
    """Switch to the next group. Not wrap around."""
    current_index = qtile.groups.index(qtile.current_group)
    last_index = len(groups) - 2  # ScratchPad does not count
    if current_index < last_index:
        qtile.current_screen.next_group(skip_empty=True)


@lazy.function
def float_to_front(qtile):
    lazy.window.toggle_floating()
    for window in qtile.current_group.windows:
        if window.floating:
            window.cmd_bring_to_front()


def move_window_to_group(direction):
    current_group, groups = qtile.current_group, qtile.groups

    current_index = groups.index(current_group)
    target_index = (current_index + direction) % len(groups)
    target_group = groups[target_index].name

    if qtile.current_window:
        qtile.current_window.togroup(target_group, switch_group=True)


def _is_first_window(grp):
    """
    Check if the current window is the first window in the group.

    Args:
        grp: An object representing a group of windows.
    """
    return grp.current_window == grp.windows[0]


def _is_last_window(grp) -> bool:
    """
    Check if the current window is the last window in the group.

    Args:
        grp: An object representing a group of windows.
    """
    return (len(grp.windows) <= 1) or (grp.current_window == grp.windows[-1])


@lazy.function
def next_window_all_screens(qtile):
    """Focus the next window across all screens."""
    if _is_last_window(qtile.current_screen.group):
        qtile.next_screen()

    qtile.current_screen.group.layout.next()


@lazy.function
def prev_window_all_screens(qtile):
    """Focus the previous window across all screens."""
    if _is_first_window(qtile.current_screen.group):
        qtile.prev_screen()

    qtile.current_screen.group.layout.previous()


keys = []

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys += [
        Key(
            f"M-{i.name}",
            lazy.screen.toggle_group(i.name),
            desc=f"Switch to group {i.name}",
        ),
        Key(
            f"M-C-{i.name}",
            lazy.window.togroup(i.name, switch_group=True),
            desc=f"Switch to & move focused window to group {i.name}",
        ),
    ]

groups.append(
    ScratchPad(
        "scratchpad",
        [
            # DropDown('slack', 'flatpak run com.slack.Slack',
            #          match=Match(wm_class=['Slack']),
            #          width=0.8, height=0.95, x=0.1, y=0.025,
            #          on_focus_lost_hide=False),
            DropDown(
                "telegram",
                "flatpak run org.telegram.desktop",
                match=Match(
                    wm_class=re.compile(r"^(telegram\-desktop|TelegramDesktop)$")
                ),
                width=0.8,
                height=1.0,
                on_focus_lost_hide=False,
            ),
            DropDown(
                "spotify",
                "flatpak run com.spotify.Client",
                match=Match(wm_class=re.compile(r"^(spotify|Spotify)$")),
                width=1.0,
                height=1.0,
                x=0,
                y=0,
                on_focus_lost_hide=False,
            ),
        ],
    )
)

layout_defaults = {
    "border_focus": colors["yellow"],
}

layouts = [
    layout.MonadTall(**layout_defaults),
    layout.Max(**layout_defaults),
    layout.MonadWide(**layout_defaults),
]

Group(
    "2",
    layouts=[
        layout.Max(**layout_defaults),
        layout.MonadWide(**layout_defaults),
    ],
)

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


def clock_with_cal():
    return widget.Clock(
        fmt="   {}",
        format="%I:%M",
        fontsize=16,
        foreground=colors["white"],
        mouse_callbacks={
            "Button1": lazy.spawn(
                '''notify-send "$(date '+%A %F')" "$(cal --monday)"''',
                shell=True,
            ),
        },
    )


def make_screen_primary():
    return Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayoutIcon(),
                widget.Spacer(length=10),
                widget.Prompt(),
                widget.Spacer(length=10),
                widget.StatusNotifier(),
                widget.Systray(),
                widget.Spacer(),
                widget.GroupBox(
                    highlight_method="line",
                    this_current_screen_border=colors["yellow"],
                ),
                widget.Spacer(),
                widget.Chord(),
                widget.BatteryIcon(
                    mouse_callbacks={
                        "Button1": lazy.spawn(
                            'notify-send "Battery Status" "$(battery-status.sh)"',
                            shell=True,
                        ),
                        "Button2": lazy.spawn(
                            "systemsettings kcm_powerdevilprofilesconfig"
                        ),
                    }
                ),
                widget.Volume(
                    emoji=True,
                    volume_up_command="volume-notify --step 3 up",
                    volume_down_command="volume-notify --step 3 down",
                    mute_command="volume-notify mute",
                    mouse_callbacks={
                        "Button2": lazy.spawn("pavucontrol"),
                    },
                ),
                widget.DoNotDisturb(),
                clock_with_cal(),
            ],
            24,
        ),
    )


def make_screen_secondary():
    return Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayoutIcon(),
                widget.Spacer(length=10),
                widget.Spacer(),
                widget.GroupBox(
                    highlight_method="line",
                    this_current_screen_border=colors["yellow"],
                ),
                widget.Spacer(),
                widget.Chord(),
                widget.DoNotDisturb(),
                clock_with_cal(),
            ],
            24,
        ),
    )


def count_monitors():
    """
    Count the number of screens based on the output of `xrandr --listmonitors`.
    """
    result = subprocess.run(
        ["xrandr", "--listmonitors"], capture_output=True, text=True
    )
    return len(result.stdout.strip().splitlines()) - 1  # skip header


screens = [make_screen_primary()]
if count_monitors() > 1:
    # If there are multiple monitors, prepend a secondary screen.
    screens.insert(0, make_screen_secondary())

# @hook.subscribe.screen_change
# def rebuild_screens(qtile):
#     """
#     Rebuild the screens when the screen configuration changes.
#     This is useful for dynamic screen setups.
#     """
#     from libqtile import qtile

#     logger.info("Rebuilding screens due to screen change")
#     qtile.screens[:] = [make_screen(primary) for primary in build_primary_flags()]
#     qtile.cmd_reconfigure_screens()


dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="telegram-desktop"),
        Match(wm_class="Slack"),
        Match(wm_class="FreeCAD") & Match(wm_class="FreeCAD"),
        # float all windows that are transient windows for a parent window
        Match(func=lambda c: bool(c.is_transient_for())),
    ],
    no_reposition_rules=[
        Match(wm_class="ghostty")
        & Match(func=lambda c: c.window.get_name() == "ghostty-termdown"),
    ],
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"


@hook.subscribe.startup_once
def autostart():
    script = Path("~/.config/qtile/autostart.sh").expanduser()
    subprocess.Popen([script])


@hook.subscribe.client_new
async def restack_modal(window):
    state = window.window.get_net_wm_state()
    if state and "_NET_WM_STATE_MODAL" in state:
        await asyncio.sleep(0.5)
        window.focus()
        window.bring_to_front()


@hook.subscribe.client_new
def move_to_group_when_started(window):
    destination = {
        "sleek": "8",
        "obsidian": "9",
    }
    wm_class = window.window.get_wm_class()
    if wm_class:
        app_name = wm_class[1]
        if app_name in destination:
            window.togroup(destination[app_name])


@hook.subscribe.client_new
def termdown_style(window):
    """Set custom style for window with WM_NAME=ghostty-termdown."""
    # If class is ghostty, wait 0.5 seconds to let the window manager
    # set the window name.
    if "ghostty" not in window.window.get_wm_class():
        return
    sleep(0.5)

    wm_name = window.window.get_name()
    if wm_name == "ghostty-termdown":
        width, height = 600, 400
        x_right = qtile.current_screen.x + qtile.current_screen.width
        window.floating = True
        window.set_size_floating(width, height)
        # Position near to the top-right corner
        window.set_position_floating(x_right - width - 10, 10)


keys += [
    # Switch between windows
    Key("M-<Tab>", next_window_all_screens, desc="Cycle windows"),
    Key("M-S-<Tab>", prev_window_all_screens, desc="Cycle windows in reverse"),
    Key("M-j", lazy.group.next_window(), desc="Focus next window in group"),
    Key(
        "M-k",
        lazy.group.prev_window(),
        desc="Focus previous window in group",
    ),
    #
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key("M-C-h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key("M-C-l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key("M-C-j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key("M-C-k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key("M-C-<Return>", lazy.layout.swap_main(), desc="Swap window to main partition"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key("M-A-h", lazy.layout.shrink_main(), desc="Shrink main window"),
    Key("M-A-l", lazy.layout.grow_main(), desc="Grow main window"),
    Key("M-A-j", lazy.layout.grow(), desc="Grow window"),
    Key("M-A-k", lazy.layout.shrink(), desc="Shrink window"),
    Key("M-A-n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Group management.
    Key("M-u", prev_group_or_stay, desc="Switch to previous group"),
    Key("M-i", next_group_or_stay, desc="Switch to next group"),
    Key(
        "M-C-u",
        lazy.function(lambda _: move_window_to_group(-1)),
        desc="Move window to previous group",
    ),
    Key(
        "M-C-i",
        lazy.function(lambda _: move_window_to_group(1)),
        desc="Move window to next group",
    ),
    Key("M-o", lazy.next_screen(), desc="Next monitor"),
    Key(
        "M-C-o",
        lazy.function(window_to_next_screen, switch_screen=True),
        desc="Move window to next monitor",
    ),
    # Layout management.
    # Key("M-<Tab>", lazy.next_layout(), desc="Toggle between layouts"),
    Key("M-<space>", lazy.next_layout(), desc="Toggle between layouts"),
    Key(
        "M-f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        "M-t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    # Qtile management.
    Key("M-q", lazy.window.kill(), desc="Kill focused window"),
    Key("M-A-r", lazy.reload_config(), desc="Reload the config"),
    Key("M-A-q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key("M-A-S-r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

# mmedia shortcuts
keys += [
    Key(
        "<XF86AudioRaiseVolume>",
        lazy.spawn("volume-notify --step 3 up"),
        desc="Raise volume",
    ),
    Key(
        "<XF86AudioLowerVolume>",
        lazy.spawn("volume-notify --step 3 down"),
        desc="Lower volume",
    ),
    Key("<XF86AudioMute>", lazy.spawn("volume-notify mute"), desc="Mute volume"),
    Key(
        "M-<XF86AudioRaiseVolume>",
        lazy.spawn("xdotool sleep 0.2 key greater"),
        desc="Play youtube faster",
    ),
    Key(
        "M-<XF86AudioLowerVolume>",
        lazy.spawn("xdotool sleep 0.2 key less"),
        desc="Play youtube slower",
    ),
    Key("M-<Prior>", lazy.spawn("volume-notify --step 3 up"), desc="Raise volume"),
    Key("M-<Next>", lazy.spawn("volume-notify --step 3 down"), desc="Lower volume"),
    Key("M-m", lazy.spawn("volume-notify mute"), desc="Mute volume"),
    Key(
        "<XF86AudioPlay>",
        lazy.spawn("playerctl play-pause"),
        lazy.spawn('notify-send -t 3000 "Toggle play/pause"'),
    ),
    Key("<XF86AudioNext>", lazy.spawn("playerctl next")),
    Key("<XF86AudioPrev>", lazy.spawn("playerctl previous")),
    KeyChord(
        "M-p",
        [
            Key(
                "k",
                lazy.spawn("playerctl play-pause"),
                lazy.spawn('notify-send -t 3000 "Toggle play/pause"'),
            ),
            Key(
                "<space>",
                lazy.spawn("playerctl play-pause"),
                lazy.spawn('notify-send -t 3000 "Toggle play/pause"'),
            ),
            Key("j", lazy.spawn("playerctl previous")),
            Key("l", lazy.spawn("playerctl next")),
            Key("<Prior>", lazy.spawn("playerctl previous")),
            Key("<Next>", lazy.spawn("playerctl next")),
        ],
        name="||| PLAYER |||        J - previous  ||  K - play  ||  L - next        ",
    ),
]

# Misc shortcuts
keys += [
    Key("<f1>", lazy.spawn("mute-meet.sh"), desc="Mute/unmute video call"),
    Key(
        "<f7>",
        lazy.group["scratchpad"].dropdown_toggle("telegram"),
        desc="Toggle telegram",
    ),
    Key("<f8>", lazy.group["scratchpad"].dropdown_toggle("slack"), desc="Toggle slack"),
    Key(
        "<f9>",
        lazy.group["scratchpad"].dropdown_toggle("spotify"),
        desc="Toggle spotify",
    ),
    Key(
        "<XF86Launch8>",
        lazy.spawn("firefox-detach-window.sh"),
        desc="Detach tab on firefox",
    ),
    Key("M-<Return>", lazy.spawn(terminal), desc="Launch terminal"),
    Key("M-A-a", lazy.spawn("autorandr 01"), desc="Call autorandr"),
    Key("M-r", lazy.spawn("ulauncher-toggle"), desc="Call ulauncher"),
    Key(
        "M-<Escape>",
        lazy.spawn("ulauncher-toggle"),
        lazy.spawn("xdotool sleep 0.2 type --clearmodifiers 'sm '"),
        desc="Call ulauncher plugin for logout, reboot, etc.",
    ),
    Key("C-A-l", lazy.spawn("xset s activate"), desc="Activate screensaver"),
    Key("M-y", lazy.spawn("thunar"), desc="Open file browser"),
    Key("<Print>", lazy.spawn("flameshot gui"), desc="Take a screenshot"),
    Key(
        "<XF86MonBrightnessUp>",
        lazy.spawn("light -A 15"),
        desc="Increase screen brightness",
    ),
    Key(
        "<XF86MonBrightnessDown>",
        lazy.spawn("light -U 15"),
        desc="Increase screen brightness",
    ),
    # MY usb knob is configured to send XF86AudioLowerVolume and
    # XF86AudioRaiseVolume for left/right turns respectively.
    #
    # Press Shift while turning to control speed in Youtube.
    Key(
        "S-<XF86AudioLowerVolume>",
        lazy.spawn("xsendkey youtube less"),
        desc="(Youtube) Decrease playback speed",
    ),
    Key(
        "S-<XF86AudioRaiseVolume>",
        lazy.spawn("xsendkey youtube greater"),
        desc="(Youtube) Increase playback speed",
    ),
    # Press Control while turning to control forward/backward seek
    # in Youtube.
    Key(
        "C-<XF86AudioLowerVolume>",
        lazy.spawn("xsendkey youtube Left"),
        desc="(Youtube) Backward 10 seconds",
    ),
    Key(
        "C-<XF86AudioRaiseVolume>",
        lazy.spawn("xsendkey youtube Right"),
        desc="(Youtube) Forward 10 seconds",
    ),
]

mouse = [
    # Drag floating layouts.
    Drag(
        "M-1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag("M-3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    # Bring window to front.
    Click("M-2", lazy.window.bring_to_front()),
    # mouse wheel left/right button switch to prev/next desktop
    Click("6", prev_group_or_stay),
    Click("7", next_group_or_stay),
    # super + scroll changes window size
    Click("M-4", lazy.layout.grow()),
    Click("M-5", lazy.layout.shrink()),
    # button8: Mouse 'forward' button.
    # button9: Mouse 'back' button.
]
