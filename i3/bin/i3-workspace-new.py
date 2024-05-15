#!/usr/bin/env python3
# i3-workspace-new.py

import i3ipc
import re
from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description='''
    Simple script to go to a new workspace. It will switch to a workspace with the lowest available number.
    ''')
    parser.add_argument('-m', '--move', action='store_true')
    args = parser.parse_args()

    i3 = i3ipc.Connection()

    workspaces = i3.get_workspaces()
    numbered_workspaces = filter(lambda w: w.name[0].isdigit(), workspaces)
    numbers = list(map(lambda w: int(re.search(r'^([0-9]+)', w.name).group(0)),
                       numbered_workspaces))

    new = 0

    for i in range(1, max(numbers) + 2):
        if i not in numbers:
            new = i
            break

    if args.move:
        i3.command(f'move container to workspace "{new}"; workspace "{new}"')
    else:
        i3.command("workspace %s" % new)


if __name__ == '__main__':
    main()
