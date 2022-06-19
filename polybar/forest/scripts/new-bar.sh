#!/usr/bin/env bash

dir="~/.config/polybar/forest/scripts/rofi"
uptime=$(uptime -p | sed -e 's/up //g')
rofi_command="rofi -theme $dir/powermenu.rasi"
# Options
powerOn=" Power On"
powerOff=" Power Off"


# Confirmation
confirm_exit() {
	rofi -dmenu\
		-i\
		-no-fixed-num-lines\
		-p "Are You Sure? : "\
		-theme $dir/confirm.rasi
}

# Message
msg() {
	rofi -theme "$dir/message.rasi" -e "Available Options  -  yes / y / no / n"
}
if [ -z "$(bluetoothctl show | grep 'Powered: no')" ];
then
	options="$powerOff"
	devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
	arr=($devices_paired)
	for index in "${!arr[@]}"
	do
		options="$options\n$(bluetoothctl info "${arr[$index]}" | grep 'Name' | cut -d ' ' -f 2) - ${arr[$index]}"
	done
else
	options="$powerOn"
	devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
	arr=($devices_paired)
	for index in "${!arr[@]}"
	do
		options="$options\n$(bluetoothctl info "${arr[$index]}" | grep 'Name' | cut -d ' ' -f 2) - ${arr[$index]}"
	done
fi
chosen="$(echo -e "$options" | $rofi_command -p "Bluetooth - Settings" -dmenu -selected-row 0)"

case $chosen in
	$powerOn)
		bluetoothctl power on
		send_no
		notify-send "bluetooth" "on"
		;;
	$powerOff)
		bluetoothctl  power off
		notify-send "bluetooth" "off"
		;;
	*)
		//cehck if $chosen is not empty
		if [ ! -z "$chosen" ];
		then
			// split $chosen by -
			IFS='- ' read -ra ADDR <<< "$chosen"
			// get the second part of the array
			chosen_device=${ADDR[1]}
			bluetoothctl power on
			bluetoothctl connect "$chosen_device"
			notify-send "bluetooth" "connected to $chosen_device"
		fi
		;;
esac

