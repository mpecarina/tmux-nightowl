#!/usr/bin/env bash
# Built-in "nightowl" theme palette (bash 3.2 compatible).
#
# This file is sourced by `scripts/nightowl.sh`.
# It exports simple variables (NOT associative arrays) so it works on macOS's
# default Bash 3.2.
#
# Key naming convention:
#   - Base:   NO_bg, NO_fg, NO_surface
#   - Border: NO_border, NO_border_active
#   - Accent: NO_accent_blue, NO_accent_cyan, NO_accent_cyan_bright, ...
#
# NOTE: Keep keys in sync across themes.

# Base
NO_bg="#0b2942"
NO_fg="#ffffff"
NO_surface="#01111d"

# Borders
NO_border="#5f7e97"
NO_border_active="#64B5F6"

# Accents
NO_accent_blue="#82aaff"
NO_accent_cyan="#21c7a8"
NO_accent_cyan_bright="#7fdbca"
NO_accent_green="#22da6e"
NO_accent_pink="#c792ea"
NO_accent_orange="#df5f00"
NO_accent_orange_bright="#f78c6c"
NO_accent_yellow="#addb67"
NO_accent_yellow_bright="#ffeb95"
NO_accent_red="#ef5350"
