# Night Owl for [tmux](https://github.com/tmux/tmux/wiki)

> A dark theme for [tmux](https://github.com/tmux/tmux/wiki) using the beautiful [Night Owl colorscheme originally created by @sdras](https://github.com/sdras/night-owl-vscode-theme)

## Screenshot



## Install

Install using tpm. If you are a tpm user, you can install the theme and keep up to date by adding the following to your `.tmux.conf`:

```/dev/null/tmux.conf#L1-1
set -g @plugin 'kylepeeler/tmux-nightowl'
```

## Activating theme

1. Make sure `run -b '~/.tmux/plugins/tpm/tpm'` is at the bottom of your `.tmux.conf`
2. Run tmux
3. Use the tpm install command: prefix + I (default prefix is ctrl+b)

## Theme selection

Built-in themes:

- `nightowl` (default)
- `shaman` (pairs well with the iTerm2 “Shaman” scheme)

Select a theme via `@nightowl-theme`:

```/dev/null/tmux.conf#L1-4
# default
set -g @nightowl-theme "nightowl"

# Shaman-complement preset
set -g @nightowl-theme "shaman"
```

### Note on macOS (bash 3.2)

On macOS, tmux plugins often run under Bash 3.2 (the system default). Bash 3.2 does not support associative arrays, so theme palettes are implemented using plain variables.

## Creating a new theme

To add your own theme, create a new file under:

- `scripts/themes/<theme-name>.sh`

Then select it in your `.tmux.conf`:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-theme "<theme-name>"
```

### Theme file format (bash 3.2 compatible)

A theme file is a simple list of `NO_*` variables containing hex colors (e.g. `#rrggbb`). Hyphens in keys become underscores in variable names.

Supported keys:

**Base**
- `bg` → `NO_bg`
- `fg` → `NO_fg`
- `surface` → `NO_surface`

**Borders**
- `border` → `NO_border`
- `border-active` → `NO_border_active`

**Accents**
- `accent-blue` → `NO_accent_blue`
- `accent-cyan` → `NO_accent_cyan`
- `accent-cyan-bright` → `NO_accent_cyan_bright`
- `accent-green` → `NO_accent_green`
- `accent-pink` → `NO_accent_pink`
- `accent-orange` → `NO_accent_orange`
- `accent-orange-bright` → `NO_accent_orange_bright`
- `accent-yellow` → `NO_accent_yellow`
- `accent-yellow-bright` → `NO_accent_yellow_bright`
- `accent-red` → `NO_accent_red`

Example theme file:

```/dev/null/shaman-example.sh#L1-25
#!/usr/bin/env bash

# Base
NO_bg="#001011"
NO_fg="#53FBDA"
NO_surface="#071411"

# Borders
NO_border="#2B3A30"
NO_border_active="#53FBDA"

# Accents
NO_accent_blue="#869A86"
NO_accent_cyan="#19655D"
NO_accent_cyan_bright="#90FDD5"
NO_accent_green="#2CA940"
NO_accent_pink="#53FBDA"
NO_accent_orange="#9D5900"
NO_accent_orange_bright="#9D5900"
NO_accent_yellow="#90FDD5"
NO_accent_yellow_bright="#90FDD5"
NO_accent_red="#B2322D"
```

### Extending a theme (recommended approach)

If you want to “base” your theme on an existing one:

1. Copy an existing theme file (e.g. `scripts/themes/nightowl.sh`) to a new name.
2. Change only the variables you care about.
3. Keep any variables you don’t change so upgrades don’t surprise you.

If you prefer not to maintain a full theme file, you can also pick any theme and override a few colors in `.tmux.conf` using `@nightowl-color-*` (see “Color overrides”).

## Color overrides

You can override any theme color (including the main status bar background) by setting `@nightowl-color-<key>` in your `.tmux.conf`.

Overrides are applied on top of the selected theme:

```/dev/null/tmux.conf#L1-4
set -g @nightowl-theme "shaman"
set -g @nightowl-color-bg "#001011"
set -g @nightowl-color-border-active "#53FBDA"
```

### Resetting sticky overrides

tmux `set -g` options persist in the tmux server even if you later remove the line from `.tmux.conf`. If you’ve experimented with `@nightowl-color-*` overrides and want to return to the theme defaults, you can do a one-shot reset:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-reset-overrides true
```

On the next theme load, the plugin will clear all `@nightowl-color-*` options and automatically set `@nightowl-reset-overrides` back to `false`.

### Recommended (user-friendly) keys

These keys are intended to be self-explanatory and stable:

```/dev/null/tmux.conf#L1-20
# main/status bar background + primary text
set -g @nightowl-color-bg "#0b2942"
set -g @nightowl-color-fg "#ffffff"

# darker “surface” used for some segments
set -g @nightowl-color-surface "#01111d"

# borders
set -g @nightowl-color-border "#5f7e97"
set -g @nightowl-color-border-active "#64B5F6"

# accents
set -g @nightowl-color-accent-blue "#82aaff"
set -g @nightowl-color-accent-cyan "#21c7a8"
set -g @nightowl-color-accent-green "#22da6e"
set -g @nightowl-color-accent-pink "#c792ea"
set -g @nightowl-color-accent-orange "#df5f00"
set -g @nightowl-color-accent-yellow "#addb67"
set -g @nightowl-color-accent-red "#ef5350"

# brighter accents (used for CPU/GPU, etc)
set -g @nightowl-color-accent-yellow-bright "#ffeb95"
set -g @nightowl-color-accent-orange-bright "#f78c6c"
set -g @nightowl-color-accent-cyan-bright "#7fdbca"
```

## Configuration

Customize the status bar by adding any of these lines to your `.tmux.conf` as desired:

### Weather location override (proxy/VPN friendly)

By default, weather uses IP-based geolocation via `ipinfo.io` to discover your location. If you use a SOCKS proxy/VPN, this can be wrong.

You can force the weather location by setting:

- `@nightowl-weather-zip` (US ZIP code used for the NOAA lookup)
- `@nightowl-weather-country` (defaults to the detected country; set to `"US"` to enable NOAA output)

Example:

```/dev/null/tmux.conf#L1-2
set -g @nightowl-weather-zip "10001"
set -g @nightowl-weather-country "US"
```

Disable battery functionality:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-battery false
```

Disable network functionality:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-network false
```

Disable weather functionality:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-weather false
```

Set cache duration to 30 minutes (1800 seconds):

```/dev/null/tmux.conf#L1-1
set -g @nightowl-weather-cache-duration 1800
```

Switch from default fahrenheit to celsius:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-fahrenheit false
```

Enable powerline symbols:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-powerline true
```

Switch left powerline symbol (can set any symbol you like as separator):

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-left-sep n8
```

Switch right powerline symbol (can set any symbol you like as separator):

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-right-sep n
```

Enable military time:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-military-time true
```

Disable timezone:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-timezone false
```

Disable the entire datetime segment (date/time/timezone):

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-datetime false
```

Hide the date (and weekday) so the segment shows only the time (timezone remains configurable via `@nightowl-show-timezone`):

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-date false
```

Switch the left icon (it can accept session, smiley, window, or any character):

```/dev/null/tmux.conf#L1-1
set -g @nightowl-show-left-icon session
```

Enable high contrast pane border:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-border-contrast true
```

Enable cpu usage:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-cpu-usage true
```

Enable ram usage:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-ram-usage true
```

Enable gpu usage:

```/dev/null/tmux.conf#L1-1
set -g @nightowl-gpu-usage true
```

## Features

* Support for powerline
* Day, date, time, timezone (configurable)
* Current location based on network with temperature and forecast icon (if available)
* Network connection status and SSID
* Battery percentage and AC power connection status
* CPU usage
* RAM usage
* GPU usage
* Color code based on if prefix is active or not
* List of windows with current window highlighted
* When prefix is enabled smiley face turns from green to yellow
* When charging, 'AC' is displayed
* If forecast information is available, a ☀, ☁, ☂, or ❄ unicode character corresponding with the forecast is displayed alongside the temperature

## Compatibility

Compatible with macOS and Linux. Tested on tmux 3.0a

## Contributors

This theme is maintained by the following person: [Kyle Peeler](https://github.com/kylepeeler)

[](https://github.com/kylepeeler) |
--- |
[Kyle Peeler](https://kylepeeler.codes) |

## License

[MIT License](./LICENSE)