import subprocess
from pathlib import Path

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import DropDown
from libqtile.config import EzClick as Click
from libqtile.config import EzDrag as Drag
from libqtile.config import EzKey as Key
from libqtile.config import EzKeyChord as KeyChord
from libqtile.config import Group, Match, ScratchPad, Screen
from libqtile.lazy import lazy
from libqtile.log_utils import logger
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal()

colors = {
    'white':    '#ffffff',
    'red':      'ff0000',
    'yellow':   'c18f41',
    'grey':     '404040',
}

def window_to_next_screen(qtile, switch_group=False, switch_screen=False):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        dest_idx = i + 1
    else:
        dest_idx = 0
    group = qtile.screens[dest_idx].group.name
    qtile.current_window.togroup(group, switch_group=switch_group)
    if switch_screen:
        qtile.to_screen(dest_idx)

@lazy.function
def prev_group_or_stay(qtile):
    current_index = qtile.groups.index(qtile.current_group)
    if current_index > 0:
        qtile.current_screen.prev_group(skip_empty=True)

@lazy.function
def next_group_or_stay(qtile):
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



keys = [
    # Switch between windows
    Key("M-h", lazy.layout.left(), desc="Move focus to left"),
    Key("M-l", lazy.layout.right(), desc="Move focus to right"),
    Key("M-j", lazy.layout.down(), desc="Move focus down"),
    Key("M-k", lazy.layout.up(), desc="Move focus up"),
    #
    Key("M-<space>", lazy.layout.next(), desc="Move window focus to other window"),
    Key("M-S-<space>", lazy.layout.previous(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key("M-C-h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key("M-C-l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key("M-C-j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key("M-C-k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key("M-C-<Return>", lazy.layout.swap_main(), desc="Swap window to main partition"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key("M-C-S-h", lazy.layout.shrink_main(), desc="Shrink main window"),
    Key("M-C-S-l", lazy.layout.grow_main(), desc="Grow main window"),
    Key("M-C-S-j", lazy.layout.grow(), desc="Grow window"),
    Key("M-C-S-k", lazy.layout.shrink(), desc="Shrink window"),
    Key("M-C-S-n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Group management.
    Key("M-u", prev_group_or_stay, desc="Switch to previous group"),
    Key("M-i", next_group_or_stay, desc="Switch to next group"),
    Key("M-C-u", lazy.function(lambda q: move_window_to_group(-1)), desc="Move window to previous group"),
    Key("M-C-i", lazy.function(lambda q: move_window_to_group(1)), desc="Move window to next group"),

    Key("M-o", lazy.next_screen(), desc='Next monitor'),
    Key("M-C-o", lazy.function(window_to_next_screen, switch_screen=True), desc='Move window to next monitor'),

    # Layout management.
    Key("M-<Tab>", lazy.next_layout(), desc="Toggle between layouts"),
    Key("M-f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Key("M-t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),

    # Qtile management.
    Key("M-q", lazy.window.kill(), desc="Kill focused window"),
    Key("M-A-r", lazy.reload_config(), desc="Reload the config"),
    Key("M-A-q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key("M-A-S-r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys += [
        Key(f"M-{i.name}", lazy.screen.toggle_group(i.name),
            desc=f"Switch to group {i.name}"),
        Key(f"M-S-{i.name}", lazy.window.togroup(i.name, switch_group=True),
            desc=f"Switch to & move focused window to group {i.name}"),
    ]

groups.append(ScratchPad('scratchpad', [
    # DropDown('slack', 'flatpak run com.slack.Slack',
    #          match=Match(wm_class=['Slack']),
    #          width=0.8, height=0.95, x=0.1, y=0.025,
    #          on_focus_lost_hide=False),
    DropDown('telegram', 'flatpak run org.telegram.desktop',
             match=Match(wm_class=["telegram-desktop", "TelegramDesktop"]),
             width=0.8, height=1.0,
             on_focus_lost_hide=False),
    DropDown('spotify', 'flatpak run com.spotify.Client',
             match=Match(wm_class=["spotify", "Spotify"]),
             width=1.0, height=1.0, x=0, y=0,
             on_focus_lost_hide=False),
]))

layout_defaults = {
    "border_focus": colors["yellow"],
}

layouts = [
    layout.MonadTall(**layout_defaults),
    layout.Max(**layout_defaults),
    layout.MonadWide(**layout_defaults),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayoutIcon(),
                widget.Spacer(length=10),
                widget.Prompt(),
                widget.Chord(
                    chords_colors={
                        "launch": (colors["red"], colors["white"]),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Spacer(length=10),
                widget.Systray(),
                widget.Spacer(),
                widget.GroupBox(
                    highlight_method='line',
                    this_current_screen_border=colors["yellow"],
                ),
                widget.Spacer(),
                widget.Clock(
                    format="%I:%M",
                    fontsize=16,
                    foreground=colors['white'],
                ),
            ],
            24,
        ),
    ),
    Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayoutIcon(),
                widget.Spacer(length=10),
                widget.Chord(
                    chords_colors={
                        "launch": (colors["red"], colors["white"]),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Spacer(),
                widget.GroupBox(
                    highlight_method='line',
                    this_current_screen_border=colors["yellow"],
                ),
                widget.Spacer(),
                widget.Clock(format="%I:%M", fontsize=16),
            ],
            24,
        ),
    ),
]

mouse = [
    # Drag floating layouts.
    Drag("M-Mouse-1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag("M-Mouse-3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    # Bring window to front.
    Click("M-Mouse-2", lazy.window.bring_to_front()),
    # horizontal scroll or wheel mouse left/right click
    Click("Mouse-6", prev_group_or_stay),
    Click("Mouse-7", next_group_or_stay),
]

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
    ]
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
    script = Path('~/.config/qtile/autostart.sh').expanduser()
    subprocess.Popen([script])




keys += [
    Key("<f7>", lazy.group['scratchpad'].dropdown_toggle('telegram'), desc="Toggle telegram"),
    Key("<f8>", lazy.group['scratchpad'].dropdown_toggle('slack'), desc="Toggle slack"),
    Key("<f9>", lazy.group['scratchpad'].dropdown_toggle('spotify'), desc="Toggle spotify"),

    Key("<f1>", lazy.spawn("mute-meet.sh"), desc="Mute/unmute video call"),
    Key("<XF86Launch8>", lazy.spawn("firefox-detach-window.sh"), desc="Detach tab on firefox"),
    Key("<XF86Launch7>", lazy.spawn("copypaster copy"), desc="Custom copy"),
    Key("<XF86Launch6>", lazy.spawn("copypaster paste"), desc="Custom paste"),

    Key("<XF86AudioRaiseVolume>", lazy.spawn("volume-notify --step 3 up"), desc="Raise volume"),
    Key("<XF86AudioLowerVolume>", lazy.spawn("volume-notify --step 3 down"), desc="Lower volume"),
    Key("<XF86AudioMute>", lazy.spawn("volume-notify mute"), desc="Mute volume"),
    Key("M-<Prior>", lazy.spawn("volume-notify --step 3 up"), desc="Raise volume"),
    Key("M-<Next>", lazy.spawn("volume-notify --step 3 down"), desc="Lower volume"),
    Key("M-m", lazy.spawn("volume-notify mute"), desc="Mute volume"),

    Key("<XF86AudioPlay>", lazy.spawn('playerctl -p spotify play-pause'), lazy.spawn('notify-send -t 3000 "Spotify: toggle-play"')),
    Key("<XF86AudioNext>", lazy.spawn('playerctl -p spotify next')),
    Key("<XF86AudioPrev>", lazy.spawn('playerctl -p spotify previous')),
    KeyChord("M-p",
        [
            Key("k", lazy.spawn('playerctl -p spotify play-pause'), lazy.spawn('notify-send -t 3000 "Spotify: toggle-play"')),
            Key("<space>", lazy.spawn('playerctl -p spotify play-pause'), lazy.spawn('notify-send -t 3000 "Spotify: toggle-play"')),
            Key("j", lazy.spawn('playerctl -p spotify previous')),
            Key("l", lazy.spawn('playerctl -p spotify next')),
            Key("<Prior>", lazy.spawn('playerctl -p spotify previous')),
            Key("<Next>", lazy.spawn('playerctl -p spotify next')),
        ],
    ),
    Key("M-<Return>", lazy.spawn(terminal), desc="Launch terminal"),
    Key("M-S-a", lazy.spawn("autorandr 1"), desc="Call autorandr"),
    Key("M-r", lazy.spawn("ulauncher-toggle"), desc="Call ulauncher"),
    Key("M-<Escape>", lazy.spawn("ulauncher-toggle"),
        lazy.spawn("xdotool sleep 0.2 type --clearmodifiers 'sm '"),
        desc="Call ulauncher plugin for logout, reboot, etc."),
    Key("C-A-l", lazy.spawn("xset s activate"), desc="Activate screensaver"),
    Key("M-y", lazy.spawn("dolphin"), desc="Call dolphin"),
    Key("<Print>", lazy.spawn("flameshot gui"), desc="Take a screenshot"),
    Key("<XF86MonBrightnessDown>", lazy.spawn("light -U 15"), desc="Decrease screen brightness"),
    Key("<XF86MonBrightnessUp>", lazy.spawn("light -A 15"), desc="Increase screen brightness"),
]
