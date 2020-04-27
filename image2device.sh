#!/usr/bin/env bash

# Author: Yuriy Gritsenko
# URL: https://github.com/yuravg/image2device
# Time-stamp: <2020-04-27 11:01:48>
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

SCRIPT_NAME=$(basename "$0")
SCRIPT_VERSION="0.1"

if [ "$1" = '-V' ] || [ "$1" = '--version' ]; then
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
    exit 0
fi

if [ "$#" -ne 2 ] || [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = '-help' ]; then
    echo ""
    echo " Usage:"
    echo "   $SCRIPT_NAME [<path-to-image> <path-to-device>]"
    echo "                 [--help | -h] [--version | -V]"
    echo " Usage example:"
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

underline_echo (){
    printf "\\e[4m%s\\e[0m\\n" "$1"
}
green_echo (){
    printf "\\e[32m%s\\e[0m\\n" "$1"
}
red_echo (){
    printf "\\e[31m\\e[1m%s\\e[0m\\n" "$1"
}

if [ ! -s "$1" ]; then
    red_echo "ERROR! Can't find image file(or zero size): '$1'!"
    exit 2
else
    IMAGE_FILE="$1"
fi

if [ ! -b "$2" ]; then
    red_echo "ERROR! Can't find block device: '$2'"
    exit 3
else
    DEVICE="$2"
fi

echo ""
underline_echo "Settings:"
echo "  work directory : $(pwd)"
echo "  image          : $IMAGE_FILE"
echo "  device         : $DEVICE"
echo ""

underline_echo "Block device:"
lsblk -p "$DEVICE"
echo ""

umount_part () {
    cnt_dev=1
    for p in $(mount|grep sdc|cut -d' ' -f3); do
        part[$cnt_dev]=$p
        cnt_dev=$((cnt_dev + 1))
    done

    for (( i=1; i<${#part[@]}+1; i++ )); do
        path2part=${part[$i]}
        # unset or empty string
        if [ -z "$1" ]; then
            echo "$path2part"
        else
            sudo umount "$path2part"
        fi
    done
}

if mount | grep -c "$DEVICE" &>/dev/null; then
    red_echo "Error! Unable write to mounted device: $DEVICE"
    echo "You should unmount the device before writing!"
    echo "Mounted parts of '$DEVICE':"
    umount_part
    if fun_yesno "Would you like unmout them"; then
        echo 'Unmout ...'
        umount_part "umount"
    else
        exit 0
    fi
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
