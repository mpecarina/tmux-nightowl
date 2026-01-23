#!/usr/bin/env bash
# "shaman" theme palette for tmux-nightowl (bash 3.2 compatible).
#
# This file is sourced by `scripts/nightowl.sh`.
#
# IMPORTANT:
# - macOS ships bash 3.2, which does NOT support associative arrays.
# - Therefore this theme exports simple variables instead of NO_PALETTE[...] maps.
#
# Key naming:
#   NO_<key> for base/border colors
#   NO_accent_<name> for accents
#
# Keys correspond to the "user-friendly" override keys:
#   bg, fg, surface, border, border-active
#   accent-blue, accent-cyan, accent-cyan-bright, accent-green, accent-pink,
#   accent-orange, accent-orange-bright, accent-yellow, accent-yellow-bright,
#   accent-red
#
# Goal: complement the iTerm2 "Shaman" scheme (dark, earthy bg with aqua accents).

# Base
NO_bg="#001011"       # Shaman background
NO_fg="#53FBDA"       # Shaman bold/cursor/selected-text (high contrast)
NO_surface="#071411"  # slightly lifted bg for “surface” segments

# Borders
NO_border="#2B3A30"         # subtle border (earthy/green-gray)
NO_border_active="#53FBDA"  # active border highlight (contrast mode)

# Accents (ANSI-inspired from Shaman)
NO_accent_blue="#869A86"         # muted sage/blue-gray
NO_accent_cyan="#19655D"         # deep teal
NO_accent_cyan_bright="#90FDD5"  # bright aqua (good for “info” blocks)
NO_accent_green="#2CA940"        # green
NO_accent_pink="#53FBDA"         # reuse bright aqua for “pink” slot
NO_accent_orange="#9D5900"       # burnt orange
NO_accent_orange_bright="#9D5900"
NO_accent_yellow="#90FDD5"       # Shaman “yellow” reads aqua
NO_accent_yellow_bright="#90FDD5"
NO_accent_red="#B2322D"          # red
