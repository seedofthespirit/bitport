#!/bin/bash

script_path=$(/usr/bin/realpath "$0")
script_name=$(/usr/bin/basename "$0")
script_dir=$(/usr/bin/dirname "${script_path}")
source "${script_dir}/common-utils"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_required_commands
fi
