#!/bin/sh

read -p "Are you sure? [N/y]: " reply
xrandr --output LVDS1 --auto --output VGA1 --off
[ "$reply" = "y"  ] &&
	cvt 1366 768
	xrandr --newmode "1366_768_new" $(cvt 1366 768 | tail -1 | cut -d '"' -f3)
	xrandr --addmode VGA1 1366_768_new &&
	xrandr --output VGA1 --mode 1366_768_new --right-of LVDS1 ||
		{ xrandr --output LVDS1 --auto &&
			echo Exiting... ;}
