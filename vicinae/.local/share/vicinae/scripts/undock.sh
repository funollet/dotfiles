#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title undock
# @vicinae.mode fullOutput
# @vicinae.icon 🔋
# @vicinae.description Run "moi undock".

# moi runs task, a mise-managed tool that is not on the service's PATH.
exec mise exec -- ~/.local/bin/moi undock
