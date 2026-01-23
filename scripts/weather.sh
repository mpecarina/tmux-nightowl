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

# Location overrides (to bypass IP-based geolocation, e.g. when using a proxy)
# Examples:
#   set -g @nightowl-weather-zip "10001"
#   set -g @nightowl-weather-country "US"
# If zip is set, it will be used for the NOAA request instead of ipinfo.io.
nightowl_weather_zip_override=$(get_tmux_option "@nightowl-weather-zip" "")
nightowl_weather_country_override=$(get_tmux_option "@nightowl-weather-country" "")

fahrenheit=$1
CACHE_DURATION=${2:-1800}
CACHE_DIR="$HOME/.config/tmux-nightowl"
CACHE_FILE="$CACHE_DIR/weather_cache"

mkdir -p "$CACHE_DIR"

is_cache_valid()
{
	if [ -f "$CACHE_FILE" ]; then
		local current_time=$(date +%s)
		local file_mod_time=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)
		local time_diff=$((current_time - file_mod_time))

		if [ $time_diff -lt $CACHE_DURATION ]; then
			return 0
		fi
	fi
	return 1
}

load_request_params()
{
	# Defaults from IP-based location
	city=$(curl -s https://ipinfo.io/city 2> /dev/null)
	region=$(curl -s https://ipinfo.io/region 2> /dev/null)
	zip=$(curl -s https://ipinfo.io/postal 2> /dev/null | tail -1)
	country_w_code=$(curl -w "\n%{http_code}\n" -s https://ipinfo.io/country 2> /dev/null)
	country=`grep -Eo [a-zA-Z]+ <<< "$country_w_code"`
	exit_code=`grep -Eo [0-9]{3} <<< "$country_w_code"`

	# Overrides to bypass IP-based geolocation
	if [ -n "$nightowl_weather_zip_override" ]; then
		zip="$nightowl_weather_zip_override"
	fi

	if [ -n "$nightowl_weather_country_override" ]; then
		country="$nightowl_weather_country_override"
	fi

	region_code_url=http://www.ip2country.net/ip2country/region_code.html
	weather_url=https://forecast.weather.gov/zipcity.php
}

get_region_code()
{
	curl -s $region_code_url | grep $region &> /dev/null && region=$(curl -s $region_code_url | grep $region | cut -d ',' -f 2)
	echo $region
}

weather_information()
{
	curl -sL $weather_url?inputstring=$zip | grep myforecast-current | grep -Eo '>.*<' | sed -E 's/>(.*)</\1/'
}

get_temp()
{
	if $fahrenheit; then
		echo $(weather_information | grep 'deg;F' | cut -d '&' -f 1)
	else
		echo $(( ($(weather_information | grep 'deg;F' | cut -d '&' -f 1) - 32) * 5 / 9 ))
	fi
}

forecast_unicode()
{
	forecast=$(weather_information | head -n 1)

	if [[ $forecast =~ 'Snow' ]]; then
		echo '❄ '
	elif [[ (($forecast =~ 'Rain') || ($forecast =~ 'Shower')) ]]; then
		echo '☂ '
	elif [[ (($forecast =~ 'Overcast') || ($forecast =~ 'Cloud')) ]]; then
		echo '☁ '
	elif [[ $forecast = 'NA' ]]; then
		echo ''
	else
		echo '☀ '
	fi
}

display_weather()
{
	if [ "$country" = 'US' ]; then
		echo "$(forecast_unicode)$(get_temp)° "
	else
		echo ''
	fi
}

fetch_and_cache()
{
	load_request_params

	if [[ $exit_code -eq 429 ]]; then
		echo "Request Limit Reached"
		exit
	fi

	if ping -q -c 1 -W 1 ipinfo.io &>/dev/null; then
		local result="$(display_weather)$city, $(get_region_code)"
		echo "$result" > "$CACHE_FILE"
		echo "$result"
	else
		echo "Location Unavailable"
	fi
}

main()
{
	if is_cache_valid; then
		cat "$CACHE_FILE"
	else
		fetch_and_cache
	fi
}

main
