#!/usr/bin/env bash

# Author: Yuriy Gritsenko
# URL: https://github.com/yuravg/image2device
# Time-stamp: <2023-05-05 17:24:51>
# License: MIT License. If not, see <https://www.opensource.org/licenses/MIT>.

#
# Script to copy a image-file to a block device(SD card, Flash drive, etc.),
# it is just a wrapper for the "dd" and "bmaptool" tools.
#
# Usage
#  <script_name> <path-to-image> <path-to-device>
#
# Example
#  image2device.sh ./sdimage.img /dev/sdc
#  image2device.sh -b ./sdimage.img /dev/sdc

SCRIPT_VERSION="1.0.0"

echo "+----------------------------------------------------------------------+"
echo "| Copy image file to block device                                      |"
echo "+----------------------------------------------------------------------+"

SCRIPT_NAME=$(basename "${BASH_SOURCE##*/}")

if [ "$1" = '-V' ] || [ "$1" = '--version' ]; then
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
    exit 0
fi

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] \
       || [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = '-help' ]; then
    echo "Usage:"
    echo "  $SCRIPT_NAME [-b] [image] [device]"
    echo "               [--help | -h] [--version | -V]"
    echo "ARGS:"
    echo "    <image>"
    echo "            Path to image file."
    echo "    <device>"
    echo "            Path to block device."
    echo "OPTIONS:"
    echo "    -b"
    echo "            Use 'bmaptool' to write image (by default: 'dd')."
    echo "    --version | -V"
    echo "            Prints version information."
    echo "    --help | -h"
    echo "            Prints help information."
    echo "Usage example:"
    echo "  $SCRIPT_NAME ./sdimage.img /dev/sdc"
    echo "  $SCRIPT_NAME -b ./sdimage.img /dev/sdc"
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

if [ "$1" = "-b" ]; then
    ARG_BMAP_EN=1
    ARG_IMG="$2"
    ARG_DEV="$3"
else
    ARG_BMAP_EN=0
    ARG_IMG="$1"
    ARG_DEV="$2"
fi

if [ ! -s "$ARG_IMG" ]; then
    red_echo "ERROR! Can't find image file(or zero size): '$ARG_IMG'!"
    exit 2
else
    IMAGE_FILE="$ARG_IMG"
    IMAGE_FILE_SIZE=$(du -h "$IMAGE_FILE" | awk '{print $1}')
fi

if [ ! -b "$ARG_DEV" ]; then
    red_echo "ERROR! Can't find block device: '$ARG_DEV'"
    exit 3
else
    DEVICE="$ARG_DEV"
fi

echo ""
underline_echo "Settings:"
echo "  work directory : $(pwd)"
echo "  image          : $IMAGE_FILE (size: $IMAGE_FILE_SIZE)"
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

run_cmd () {
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
}

dd_write () {
    CMD="sudo dd bs=32M conv=sync status=progress if=$IMAGE_FILE of=$DEVICE"
    run_cmd
}

btool_write() {
    BMAP_FNAME="${IMAGE_FILE%.*}-${IMAGE_FILE##*.}.bmap"

    CMD="bmaptool create -o $BMAP_FNAME $IMAGE_FILE"

    if [ -s "$BMAP_FNAME" ]; then
        BMAP_FTIME=$(date '+%Y-%m-%d %H:%M:%S' -r "$BMAP_FNAME")
        echo "Note: existing bmap-file: $BMAP_FNAME ($BMAP_FTIME),"
        echo "      will be used to write the image."
    else
        echo "Create bmap-file, run:"
        echo "$CMD"
        if ! $CMD; then
            red_echo "Error! Can not create bmap-file: $BMAP_FNAME!"
        fi
    fi

    CMD="sudo bmaptool copy --bmap $BMAP_FNAME $IMAGE_FILE $DEVICE"
    run_cmd
}

if [ "$ARG_BMAP_EN" -eq 1 ]; then
    btool_write
else
    dd_write
fi

# This is for the sake of Emacs.
# Local Variables:
# time-stamp-end: "$"
# time-stamp-format: "<%:y-%02m-%02d %02H:%02M:%02S>"
# time-stamp-start: "Time-stamp: "
# End:
