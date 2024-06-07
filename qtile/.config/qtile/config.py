# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, layout, widget, qtile, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
# from libqtile.config import EzKey as Key
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.log_utils import logger
from pathlib import Path
import subprocess

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
    if switch_screen == True:
        qtile.to_screen(dest_idx)


@lazy.function
def prev_group_or_stay(qtile):
    current_index = qtile.groups.index(qtile.current_group)
    if current_index > 0:
        qtile.current_screen.prev_group(skip_empty=True)


@lazy.function
def next_group_or_stay(qtile):
    current_index = qtile.groups.index(qtile.current_group)
    last_index = len(groups) - 2        # ScratchPad does not count
    if current_index < last_index:
        qtile.current_screen.next_group(skip_empty=True)


@lazy.function
def float_to_front(qtile):
    lazy.window.toggle_floating()
    # logger.warning("bring floating windows to front")
    for window in qtile.current_group.windows:
        if window.floating:
            window.cmd_bring_to_front()


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    #
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key([mod, "shift"], "space", lazy.layout.previous(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    # Key([mod, "control"], "h", lazy.layout.shrink_main(), desc="Grow window to the left"),
    # Key([mod, "control"], "l", lazy.layout.grow_main(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow(), desc="Grow window"),
    Key([mod, "control"], "k", lazy.layout.shrink(), desc="Shrink window"),
    Key([mod, "control"], "m", lazy.layout.maximize(), desc="Maximize"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    Key([mod], "u", prev_group_or_stay, desc="Switch to previous group"),
    Key([mod], "i", next_group_or_stay, desc="Switch to next group"),
    Key([mod, "control"], "u", lazy.function(lambda q: move_window_to_group(-1)), desc="Move window to previous group"),
    Key([mod, "control"], "i", lazy.function(lambda q: move_window_to_group(1)), desc="Move window to next group"),

    Key([mod], "o", lazy.next_screen(), desc='Next monitor'),
    Key([mod, "control"], "o", lazy.function(window_to_next_screen, switch_screen=True), desc='Move window to next monitor'),
    # # Grow windows. If current window is on the edge of screen and direction
    # # will be to screen edge - window would shrink.
    # Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    # Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    # Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    # Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    # Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    # Key(
    #     [mod, "shift"],
    #     "Return",
    #     lazy.layout.toggle_split(),
    #     desc="Toggle between split and unsplit sides of stack",
    # ),
    
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),

    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod, "mod1", "shift", ], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod, "shift"], "a", lazy.spawn("autorandr 1"), desc="Call autorandr"),
    Key([mod], "r", lazy.spawn("ulauncher-toggle"), desc="Call ulauncher"),
]


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys += [
        # mod1 + letter of group = switch to group
        Key(
            [mod],
            i.name,
            lazy.screen.toggle_group(i.name),
            desc="Switch to group {}".format(i.name),
        ),
        # mod1 + shift + letter of group = switch to & move focused window to group
        Key(
            [mod, "shift"],
            i.name,
            lazy.window.togroup(i.name, switch_group=True),
            desc="Switch to & move focused window to group {}".format(i.name),
        ),
    ]

groups.append(ScratchPad('scratchpad', [
    DropDown('slack', 'flatpak run com.slack.Slack',
             match=Match(wm_class=['Slack']),
             width=0.8, height=0.95, x=0.1, y=0.025,
             on_focus_lost_hide=False),
    DropDown('telegram', 'flatpak run org.telegram.desktop',
             match=Match(wm_class=["telegram-desktop", "TelegramDesktop"]),
             width=0.8, height=1.0,
             on_focus_lost_hide=False),
    DropDown('spotify', 'flatpak run com.spotify.Client',
             match=Match(wm_class=["spotify", "Spotify"]),
             width=1.0, height=1.0, x=0, y=0,
             on_focus_lost_hide=False),
]))

keys += [
    Key([], "f7", lazy.group['scratchpad'].dropdown_toggle('telegram'), desc="Toggle telegram"),
    Key([], "f8", lazy.group['scratchpad'].dropdown_toggle('slack'), desc="Toggle slack"),
    Key([], "f9", lazy.group['scratchpad'].dropdown_toggle('spotify'), desc="Toggle spotify"),
]

layout_defaults = {
        "border_focus": colors["yellow"],
        }

layouts = [
    layout.MonadTall(**layout_defaults),
    layout.Max(**layout_defaults),
    layout.VerticalTile(**layout_defaults),
]

layout_defaults = {
        "border_focus": colors["yellow"],
        }
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

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
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
    home = Path('~/.config/qtile/autostart.sh').expanduser()
    subprocess.Popen([home])


def move_window_to_group(direction):
    current_group, groups = qtile.current_group, qtile.groups

    current_index = groups.index(current_group)
    target_index = (current_index + direction) % len(groups)
    target_group = groups[target_index].name

    if qtile.current_window:
        qtile.current_window.togroup(target_group, switch_group=True)
