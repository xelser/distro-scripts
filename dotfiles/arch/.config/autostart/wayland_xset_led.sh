#!/bin/bash

while true; do
	input_num="$(ls /sys/class/leds/input*::scrolllock/brightness | cut -d':' -f1)"
	echo 1 | sudo tee "${input_num}::scrolllock/brightness" 1>/dev/null
done
