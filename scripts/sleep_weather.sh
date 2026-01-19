#!/usr/bin/env bash

fahrenheit=$1
cache_duration=${2:-1800}

LOCKFILE=/tmp/.nightowl-tmux-weather.lock
CACHE_DIR="$HOME/.config/tmux-nightowl"
CACHE_FILE="$CACHE_DIR/weather_cache"

ensure_single_process()
{
	[ -f $LOCKFILE ] && ps -p "$(cat $LOCKFILE)" -o cmd= | grep -F " ${BASH_SOURCE[0]}" && kill "$(cat $LOCKFILE)"
	echo $$ > $LOCKFILE
}

main()
{
	ensure_single_process

	current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	mkdir -p "$CACHE_DIR"

	$current_dir/weather.sh $fahrenheit $cache_duration

	while tmux has-session &> /dev/null
	do
		$current_dir/weather.sh $fahrenheit $cache_duration
		if tmux has-session &> /dev/null
		then
			sleep $cache_duration
		else
			break
		fi
	done

	rm $LOCKFILE
}

main
