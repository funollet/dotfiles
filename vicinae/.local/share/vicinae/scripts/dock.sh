#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title dock
# @vicinae.mode fullOutput
# @vicinae.icon 🔌
# @vicinae.description Run "moi dock".

# moi runs task, a mise-managed tool that is not on the service's PATH.
exec mise exec -- ~/.local/bin/moi dock
