#!/bin/bash
# -*- mode: sh; coding: utf-8; -*-


main() {

    local isopath
    local cmdline

    #get_cmdline cmdline
    get_cmdline_simulate cmdline
    echo "${cmdline}"

    findiso "${cmdline}" isopath
    echo "isopath: ${isopath}"

    local checksum
    map_isofile_to_checksum "${isopath}" checksum
    echo "checksum: ${checksum}"
}

findiso() {
    local cmdline="$1"
    declare -n isopath_ref="$2"
    # pick up the ISO name from kernel boot parameters.
    # One of the parameters should be findiso=${isofile}.
    #
    # A sample of /proc/cmdline:
    # BOOT_IMAGE=/live/vmlinuz-5.10.0-26-amd64 boot=live components quiet splash findiso=/isos/debian-live-bullseye-offline-amd64-hybrid-20231008.iso

    local parameter='findiso'
    isopath_ref=$(/bin/echo "${cmdline}" | /bin/sed -r "s/.* *${parameter}=([^ ]+) *.*/\1/")
}

get_cmdline() {
    declare -n cmdline_ref="$1"
    cmdline_ref=$(/bin/cat /proc/cmdline)
}

get_cmdline_simulate() {
    declare -n cmdline_ref="$1"
    cmdline_ref='BOOT_IMAGE=/live/vmlinuz-5.10.0-26-amd64 boot=live components quiet splash findiso=/isos/debian-live-bullseye-offline-amd64-hybrid-20231008.iso'
}

map_isofile_to_checksum() {
    local isopath="$1"
    declare -n checksum_ref="$2"

    local isofile
    #isofile=$(/bin/echo "${isopath}" | /bin/sed -r "s|^.*/||")
    isofile=$(/usr/bin/basename "${isopath}")

    # checksum file name = ${isofile}_sha256sum.gpg
    checksum_ref="${isofile}_sha256sum.gpg"
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    #test
    main
fi
