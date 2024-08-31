#!/bin/bash

# Default values
DEFAULT_MAX_BRIGHTNESS_SENSOR_VALUE=100
DEFAULT_MIN_BRIGHTNESS_SENSOR_VALUE=0
DEFAULT_UPDATE_INTERVAL_S=0.25
DEFAULT_MIN_BRIGHTNESS_DELTA=5
DEFAULT_MAX_BRIGHTNESS_DELTA=1

# Source the main configuration file if it exists
source_config() {
        MAIN_CONFIG_FILE="/etc/conf.d/auto-brightness.conf"
        if [ -f "$MAIN_CONFIG_FILE" ]; then
            source "$MAIN_CONFIG_FILE"
        fi
}

# Function to source individual configuration files in /etc/conf.d/auto-brightness.d/
source_individual_configs() {
    CONFIG_DIR="/etc/conf.d/auto-brightness.d/"
    if [ -d "$CONFIG_DIR" ]; then
        for config_file in "$CONFIG_DIR"/*.conf; do
            [ -f "$config_file" ] && source "$config_file"
        done
    fi
}

read_config() {
        source_config
        source_individual_configs

        # Set the configuration values, using defaults if not set in the config file or individual files
        max_brightness_sensor_value=${max_brightness_sensor_value:-$DEFAULT_MAX_BRIGHTNESS_SENSOR_VALUE}
        min_brightness_sensor_value=${min_brightness_sensor_value:-$DEFAULT_MIN_BRIGHTNESS_SENSOR_VALUE}
        update_interval_s=${update_interval_s:-$DEFAULT_UPDATE_INTERVAL_S}
        min_brightness_delta=${min_brightness_delta:-$DEFAULT_MIN_BRIGHTNESS_DELTA}
        max_brightness_delta=${max_brightness_delta:-$DEFAULT_MAX_BRIGHTNESS_DELTA}

	refresh_config_interval_s=$(if [ $(awk "BEGIN {print ($update_interval_s > 1)}") -eq 1 ]; then echo $update_interval_s; else echo 1; fi)
	refresh_config_count_max=$(awk "BEGIN {print ($refresh_config_interval_s / $update_interval_s)}")
        refresh_config_count=0
}

read_config

# Functions to find devices
find_iio_device_with_illuminance() {
    for device in /sys/bus/iio/devices/iio:device*; do
        if [ -f "$device/in_illuminance_raw" ]; then
            echo "$device"
            return 0
        fi
    done
    echo "No device with in_illuminance_raw found."
    return 1
}

find_backlight_device() {
    for device in /sys/class/backlight/*; do
        if [ -f "$device/brightness" ]; then
            echo "$device"
            return 0
        fi
    done
    echo "No device with brightness found."
    return 1
}

# Set paths, using explicit values from config or finding them
brightness_path=${brightness_path:-$(find_backlight_device)}
sensor_path=${sensor_path:-$(find_iio_device_with_illuminance)}

# Exit if devices are not found
if [[ $brightness_path == "No device with brightness found." || $sensor_path == "No device with in_illuminance_raw found." ]]; then
    echo "Required device not found. Exiting."
    exit 1
fi

# Set max_brightness, fallback to the device's max_brightness if not set or 0
if [ -z "$max_brightness" ] || [ "$max_brightness" -eq 0 ]; then
    max_brightness=$(cat ${brightness_path}/max_brightness)
fi

# Function to test write access to brightness setting
test_write_access() {
    local current_brightness=$(cat ${brightness_path}/brightness)
    if ! echo $current_brightness | tee ${brightness_path}/brightness > /dev/null 2>&1; then
        echo "Error: Unable to write to ${brightness_path}/brightness."
        echo "Please ensure the script has the necessary permissions to write to the brightness setting."
        echo "You can run the script as root or set up a proper udev rule to allow non-root users to write to the brightness setting."
        exit 1
    fi
}

# Test write access
test_write_access

# Function to set smoothly set brightness
set_brightness_smooth() {
	local target_brightness=$1

	local target=$target_brightness
	if [ $max_brightness_delta -ne -1 ]; then
		if [ $(($target_brightness - $current_brightness)) -gt $max_brightness_delta ]; then
			target=$((current_brightness + $max_brightness_delta))
		elif [ $(($current_brightness - $target_brightness)) -gt $max_brightness_delta ]; then
			target=$((current_brightness - $max_brightness_delta))
		fi
	fi

        #echo "Setting brightness to $target"
        echo $target | tee ${brightness_path}/brightness > /dev/null
}

while true; do
    if [ $refresh_config_count -eq $refresh_config_count_max ]; then
        read_config 
    fi
    current_brightness=$(cat ${brightness_path}/brightness)
    sensor=$(cat ${sensor_path}/in_illuminance_raw)

    # Clamp sensor value
    if [ $sensor -lt $min_brightness_sensor_value ]; then sensor=$min_brightness_sensor_value; fi
    if [ $sensor -gt $max_brightness_sensor_value ]; then sensor=$max_brightness_sensor_value; fi

    target_brightness=$((sensor * max_brightness / max_brightness_sensor_value))

    should_update=$(if [ $current_brightness -lt $((target_brightness - min_brightness_delta)) ] || [ $current_brightness -gt $((target_brightness + min_brightness_delta)) ]; then echo 1; else echo 0; fi)

    if [ "$should_update" -eq 1 ]; then
	set_brightness_smooth $target_brightness
	sleep 0.01
    else
    	sleep $update_interval_s
        refresh_config_count=$((refresh_config_count + 1))
    fi
done
