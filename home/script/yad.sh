#!/bin/bash

yad \
--width=950 \
--height=550 \
--center \
--fixed \
--title="Keybindings" \
--no-buttons \
--list \
--column=Key: \
--column=Description: \
--timeout=90 \
--timeout-indicator=bottom \
" + Q" "Terminal" \
" + C" "Kill active" \
" + K" "Force Kill active" \
" + L" "Lock" \
" + E" "File Manager" \
" + V" "Toggle floating" \
" + R" "App menu" \
" + P" "Pseudo dwindle" \
" + J" "Toggle split" \
" + I" "Workspace overview" \
"PRINT" "Screenshot a region" \
" + <Direction arrow>" "Move focus" \
" + SHIFT + <Direction arrow>" "Move window" \
" + S" "Toggle special workspace" \
" + <Number>" "Switch workspace" \
" + SHIFT + <Number>" "Move active window to a workspace" \
" + Tab" "Move to next workspace"
