#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value
  option_value=$(tmux show-option -gqv "$option")
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

reset_nightowl_color_overrides() {
  tmux set -gu @nightowl-color-bg
  tmux set -gu @nightowl-color-fg
  tmux set -gu @nightowl-color-surface
  tmux set -gu @nightowl-color-border
  tmux set -gu @nightowl-color-border-active
  tmux set -gu @nightowl-color-accent-blue
  tmux set -gu @nightowl-color-accent-cyan
  tmux set -gu @nightowl-color-accent-cyan-bright
  tmux set -gu @nightowl-color-accent-green
  tmux set -gu @nightowl-color-accent-pink
  tmux set -gu @nightowl-color-accent-orange
  tmux set -gu @nightowl-color-accent-orange-bright
  tmux set -gu @nightowl-color-accent-yellow
  tmux set -gu @nightowl-color-accent-yellow-bright
  tmux set -gu @nightowl-color-accent-red
}

# Returns a theme color override (if set), otherwise empty.
# Usage:
#   get_nightowl_color_override "bg"
# Reads:
#   @nightowl-color-<key>
get_nightowl_color_override() {
  local key=$1
  local v
  v=$(tmux show-option -gqv "@nightowl-color-$key")

  # Unset / empty => no override
  if [ -z "$v" ]; then
    echo ""
    return 0
  fi

  # Some setups end up "sticking" old values in the server even after you
  # remove lines from your config. Allow users to clear an override without
  # unsetting the option by treating explicit "default" as "no override".
  #
  # Example:
  #   set -g @nightowl-color-bg default
  case "$v" in
    default|DEFAULT)
      echo ""
      ;;
    *)
      echo "$v"
      ;;
  esac
}

# Loads the selected theme palette.
#
# IMPORTANT (macOS): default Bash is 3.2, which does NOT support associative arrays.
# So themes export simple variables like:
#   NO_bg, NO_fg, NO_surface,
#   NO_border, NO_border_active,
#   NO_accent_green, etc.
#
# Themes live in: scripts/themes/<theme>.sh
#
# Config:
#   set -g @nightowl-theme "nightowl"  # default
#   set -g @nightowl-theme "shaman"    # Shaman-complement theme
load_nightowl_palette() {
  local current_dir=$1
  local theme
  theme=$(get_tmux_option "@nightowl-theme" "nightowl")

  local theme_file="${current_dir}/themes/${theme}.sh"

  # Fallback to built-in "nightowl" if theme file doesn't exist.
  if [ ! -f "$theme_file" ]; then
    theme_file="${current_dir}/themes/nightowl.sh"
  fi

  # shellcheck disable=SC1090
  source "$theme_file"
}

# Maps a user-friendly key (e.g. "border-active", "accent-green") to a variable
# name exported by the theme file (e.g. "NO_border_active", "NO_accent_green").
theme_var_for_key() {
  local key=$1
  key=${key//-/_}
  echo "NO_${key}"
}

# Returns a theme color, resolved as:
#   1) @nightowl-color-<key> override (if set and non-empty)
#   2) theme variable exported by the selected theme (e.g. NO_bg / NO_accent_green)
#   3) hardcoded fallback (last resort)
get_nightowl_color() {
  local key=$1
  local fallback=$2

  local override
  override=$(get_nightowl_color_override "$key")
  if [ -n "$override" ]; then
    echo "$override"
    return 0
  fi

  local var_name value
  var_name=$(theme_var_for_key "$key")
  value=$(eval "printf '%s' \"\${$var_name-}\"")

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$fallback"
  fi
}

main()
{
  # set current directory variable
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  reset_overrides=$(get_tmux_option "@nightowl-reset-overrides" "false")
  if [ "$reset_overrides" = "true" ]; then
    reset_nightowl_color_overrides
    tmux set -g @nightowl-reset-overrides "false"
  fi

  # set configuration option variables
  show_battery=$(get_tmux_option "@nightowl-show-battery" true)
  show_network=$(get_tmux_option "@nightowl-show-network" false)
  show_weather=$(get_tmux_option "@nightowl-show-weather" true)
  show_fahrenheit=$(get_tmux_option "@nightowl-show-fahrenheit" true)
  show_powerline=$(get_tmux_option "@nightowl-show-powerline" false)
  show_left_icon=$(get_tmux_option "@nightowl-show-left-icon" "smiley")
  show_military=$(get_tmux_option "@nightowl-military-time" "false")
  show_timezone=$(get_tmux_option "@nightowl-show-timezone" "true")
  show_datetime=$(get_tmux_option "@nightowl-show-datetime" "true")
  show_date=$(get_tmux_option "@nightowl-show-date" "true")
  show_left_sep=$(get_tmux_option "@nightowl-show-left-sep" "")
  show_right_sep=$(get_tmux_option "@nightowl-show-right-sep" "")
  show_border_contrast=$(get_tmux_option "@nightowl-border-contrast" false)
  show_cpu_usage=$(get_tmux_option "@nightowl-cpu-usage" false)
  show_ram_usage=$(get_tmux_option "@nightowl-ram-usage" false)
  show_gpu_usage=$(get_tmux_option "@nightowl-gpu-usage" false)
  weather_cache_duration=$(get_tmux_option "@nightowl-weather-cache-duration" 1800)

  # Load palette for @nightowl-theme (defaults to "nightowl")
  load_nightowl_palette "$current_dir"

  # Resolve colors from palette + overrides
  # (fallbacks are kept as a last resort)
  white=$(get_nightowl_color "fg" "#ffffff")
  gray=$(get_nightowl_color "bg" "#0b2942")
  dark_gray=$(get_nightowl_color "surface" "#01111d")

  pane_border=$(get_nightowl_color "border" "#5f7e97")
  high_contrast_pane_border=$(get_nightowl_color "border-active" "#64B5F6")

  blue=$(get_nightowl_color "accent-blue" "#82aaff")
  brightCyan=$(get_nightowl_color "accent-cyan-bright" "#7fdbca")
  cyan=$(get_nightowl_color "accent-cyan" "#21c7a8")
  green=$(get_nightowl_color "accent-green" "#22da6e")
  brightOrange=$(get_nightowl_color "accent-orange-bright" "#f78c6c")
  orange=$(get_nightowl_color "accent-orange" "#df5f00")
  red=$(get_nightowl_color "accent-red" "#ef5350")
  pink=$(get_nightowl_color "accent-pink" "#c792ea")
  brightYellow=$(get_nightowl_color "accent-yellow-bright" "#ffeb95")
  yellow=$(get_nightowl_color "accent-yellow" "#addb67")


  # Handle left icon configuration
  case $show_left_icon in
      smiley)
          left_icon="☺ ";;
      session)
          left_icon="#S ";;
      window)
	  left_icon="#W ";;
      *)
          left_icon=$show_left_icon;;
  esac

  # Handle powerline option
  if $show_powerline; then
      right_sep="$show_right_sep"
      left_sep="$show_left_sep"
  fi

  # start weather script in background
  if $show_weather; then
    $current_dir/sleep_weather.sh $show_fahrenheit $weather_cache_duration &
  fi

  # Weather cache file (used by both powerline and non-powerline rendering)
  weather_cache_file="$HOME/.config/tmux-nightowl/weather_cache"

  # Set timezone unless hidden by configuration
  case $show_timezone in
      false)
          timezone="";;
      true)
          timezone="#(date +%Z)";;
  esac

  # datetime formatting configuration (weekday/date/time)
  # - @nightowl-show-datetime false => hides the whole datetime segment
  # - @nightowl-show-date false => shows only time (keeps timezone if enabled)
  if $show_military; then
    time_fmt="%R"
  else
    time_fmt="%I:%M %p"
  fi

  if $show_date; then
    datetime_fmt="%a %m/%d ${time_fmt}"
  else
    datetime_fmt="${time_fmt}"
  fi

  if $show_datetime; then
    datetime_segment="${datetime_fmt} ${timezone} "
  else
    datetime_segment=""
  fi

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval 5

  # set clock to 12 hour by default
  tmux set-option -g clock-mode-style 12

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${high_contrast_pane_border}"
  else
    tmux set-option -g pane-active-border-style "fg=${pane_border}"
  fi
  tmux set-option -g pane-border-style "fg=${gray}"

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${gray},fg=${white}"


  # Powerline Configuration
  if $show_powerline; then

      tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon} #[fg=${green},bg=${gray}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
      tmux set-option -g  status-right ""
      powerbg=${gray}

      if $show_battery; then # battery
        tmux set-option -g  status-right "#[fg=${pink},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${pink}] #($current_dir/battery.sh)"
        powerbg=${pink}
      fi

      if $show_ram_usage; then
	 tmux set-option -ga status-right "#[fg=${yellow},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${yellow}] #($current_dir/ram_info.sh)"
	 powerbg=${yellow}
      fi

      if $show_cpu_usage; then
	 tmux set-option -ga status-right "#[fg=${brightYellow},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${brightYellow}] #($current_dir/cpu_info.sh)"
	 powerbg=${brightYellow}
      fi

      if $show_gpu_usage; then
	 tmux set-option -ga status-right "#[fg=${brightOrange},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${brightOrange}] #($current_dir/gpu_usage.sh)"
	 powerbg=${brightOrange}
      fi

      if $show_network; then # network
        tmux set-option -ga status-right "#[fg=${cyan},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${cyan}] #($current_dir/network.sh)"
        powerbg=${cyan}
      fi

      if $show_weather; then # weather
        tmux set-option -ga status-right "#[fg=${blue},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${dark_gray},bg=${blue}] #(cat ${weather_cache_file})"
        powerbg=${blue}
      fi

      if $show_datetime; then # datetime (time and optional date/timezone)
	tmux set-option -ga status-right "#[fg=${orange},bg=${powerbg},nobold,nounderscore,noitalics] ${right_sep}#[fg=${white},bg=${orange}] ${datetime_segment}"
      fi

      tmux set-window-option -g window-status-current-format "#[fg=${dark_gray},bg=${dark_gray}]${left_sep}#[fg=${white},bg=${dark_gray}] #I #W #[fg=${dark_gray},bg=${dark_gray}]${left_sep}"

  # Non Powerline Configuration
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"

    tmux set-option -g  status-right ""

      if $show_battery; then # battery
        tmux set-option -g  status-right "#[fg=${dark_gray},bg=${pink}] #($current_dir/battery.sh) "
      fi
      if $show_ram_usage; then
	tmux set-option -ga status-right "#[fg=${dark_gray},bg=${yellow}] #($current_dir/ram_info.sh) "
      fi

      if $show_cpu_usage; then
	tmux set-option -ga status-right "#[fg=${dark_gray},bg=${brightYellow}] #($current_dir/cpu_info.sh) "
      fi

      if $show_gpu_usage; then
	tmux set-option -ga status-right "#[fg=${dark_gray},bg=${brightOrange}] #($current_dir/gpu_usage.sh) "
      fi

      if $show_network; then # network
        tmux set-option -ga status-right "#[fg=${dark_gray},bg=${cyan}] #($current_dir/network.sh) "
      fi

      if $show_weather; then
          tmux set-option -ga status-right "#[fg=${dark_gray},bg=${blue}] #(cat ~/.config/tmux-nightowl/weather_cache) "
      fi

      if $show_datetime; then # datetime (time and optional date/timezone)
	tmux set-option -ga status-right "#[fg=${white},bg=${orange}] ${datetime_segment}"
      fi

      tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${pane_border}] #I #W "

  fi

  tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${gray}] #I #W "
}

# run main function
main
