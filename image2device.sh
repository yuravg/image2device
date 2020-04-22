#!/usr/bin/env bash

# Author: Yuriy Gritsenko
# URL: https://github.com/yuravg/image2device
# Time-stamp: <2020-04-22 15:42:54>
# License: MIT License. If not, see <https://www.opensource.org/licenses/MIT>.

#
# Script to copy a image-file to a block device(SD card, Flash drive, etc.),
# it is just a wrapper for "dd" tool.
#
# Usage
#  <script_name> <path-to-image> <path-to-device>
#
# Example
#  image2device.sh ./sdimage.img /dev/sdc

echo "+----------------------------------------------------------------------+"
echo "| Copy image file to block device                                      |"
echo "+----------------------------------------------------------------------+"

SCRIPT_NAME="$(basename $0)"

if [ "$#" -ne 2 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ] || [ "$1" == '-help' ]; then
    echo ""
    echo " Usage:"
    echo "   <script_name> <path-to-image> <path-to-device>"
    echo " usage example:"
    echo "   $SCRIPT_NAME ./sdimage.img /dev/sdc"
    echo ""
    exit 0
fi

fun_yesno () {
    while :
    do
        echo "$* (Yes/No)?"
        read -r yn
        case $yn in
            yes|Yes|YES)
                return 0
                ;;
            no|No|NO)
                return 1
                ;;
            *)
                echo Please answer Yes or No.
                ;;
        esac
    done
}

if [ -z "$1" ]; then
    echo "ERROR! Can't find image file: '$1'!"
    exit -1
else
    IMAGE_FILE="$1"
fi

if [ -z "$2" ]; then
    echo "ERROR! You must set path to device and image to start copying!"
    exit -2
else
    DEVICE="$2"
fi

underline_echo (){
    printf "\\e[4m%s\\e[0m\\n" "$1"
}
green_echo (){
    printf "\\e[32m%s\\e[0m\\n" "$1"
}
red_echo (){
    printf "\\e[31m\\e[1m%s\\e[0m\\n" "$1"
}

echo ""
underline_echo "Settings:"
echo "  work directory : $(pwd)"
echo "  image          : $IMAGE_FILE"
echo "  device         : $DEVICE"
echo ""

underline_echo "Block device:"
lsblk -p "$DEVICE"
echo ""

if mount | grep -c "$DEVICE" &>/dev/null; then
    red_echo "Error! Unable write to mounted device: $DEVICE"
    echo "You should unmount the device before writing."
    exit 1
fi

CMD="sudo dd bs=32M conv=sync status=progress if=$IMAGE_FILE of=$DEVICE"
underline_echo "Command to execute:"
echo "$CMD"
echo ""

echo "WARNING! All data on the device ($DEVICE) will be erased!"
if ! fun_yesno "Would you like begin writing" ; then
    echo "Exit without image recording!"
    exit 1
fi

echo "Writing ..."
if ! $CMD; then
    red_echo "Error! Unable to write data."
else
    green_echo "Done."
fi

# This is for the sake of Emacs.
# Local Variables:
# time-stamp-end: "$"
# time-stamp-format: "<%:y-%02m-%02d %02H:%02M:%02S>"
# time-stamp-start: "Time-stamp: "
# End:
