# Introduction

**image2device.sh** is a script to copy a image-file to a block device(SD card, Flash drive, etc.),

it is just a wrapper for "dd" tool.

Sometimes I prefer to use this script than alias like: `alias dd_sync="dd bs=32M conv=sync status=progress"`,

and than [bmap-tools](https://github.com/intel/bmap-tools).

# Usage

## Download

To get script image2device.sh:

Download the [script](https://raw.githubusercontent.com/yuravg/image2device/master/image2device.sh)

or

Clone Git repository `git clone https://github.com/yuravg/image2device.git`

## Install

- copy the script file to some PATH directory (~/bin, /user/local/bin, etc.)

- set the script permission to execute

Example:

    $ mv -v image2device.sh ~/bin/
    $ sudo chmod +x ~/bin/image2device.sh

or

    $ sudo make install

## Write image to device

If the script is invoked without command line argument,
with command line argument --help (or -h), it shows help message and exits.

Template:

    $ <script_name> <path-to-image> <path-to-device>

Example:

    $ image2device.sh ./sdimage.img /dev/sdc

## Screenshot

![screenshot](img/image2device.png)
