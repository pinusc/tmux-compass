#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
navigate="$CURRENT_DIR/scripts/tmux-navigate.sh"

navigate_left=" $navigate 'left'"
navigate_down=" $navigate 'down'"
navigate_up="   $navigate 'up'"
navigate_right=" $navigate 'right'"

# QWERTY keys - comment these out if you don't use QWERTY layout!
tmux bind-key -n M-h run-shell -b "$navigate_left"
tmux bind-key -n M-j run-shell -b "$navigate_down"
tmux bind-key -n M-k run-shell -b "$navigate_up"
tmux bind-key -n M-l run-shell -b "$navigate_right"

