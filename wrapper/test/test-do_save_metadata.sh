#!/bin/bash

script_path=$(/usr/bin/realpath "$0")
script_name=$(/usr/bin/basename "$0")
script_dir=$(/usr/bin/dirname "${script_path}")
source "${script_dir}/electrum-luks-constants"
source "${script_dir}/linux-commands"


test_do_save_metadata() {

    local wallet_file="wallet_file"
    local wallet_metadata_dir="wallet_metadata_dir"

    local today=$(${DATE_CMD} '+%m/%d/%Y %H:%M %Z')
    local text1 text2 text3 text4 text5 text6 text7 text8 dialog_output output

    text1='<b>Metadata for wallet: '
    text2='</b>'

    local electrum_installed_version="Electrum-4.5.5"

    local yad_field_sep=$'\v'
    dialog_output=$(
        ${YAD_CMD} \
            --form \
            --title "Save Metadata for ${wallet_file}" \
            --text "${text1}${wallet_file}${text2}" \
            --field 'Electrum version:' "${electrum_installed_version}" \
            --field 'Wallet file name:' "${wallet_file}" \
            --field 'Wallet-type::CB' 'standard!two-factor authentication!multi-signature!import' \
            --field 'Seed type::CB' 'standard!segwit' \
            --field 'Seed phrase:' 'YOUR SEED PHRASE HERE' \
            --field 'Seed extension custom words:' '' \
            --field 'BIP39 seed::CB' 'No!Yes' \
            --field 'Script type::CB' 'native segwit (p2wpkh)!p2sh-segwit (p2wpkh-p2sh)!legacy (p2pkh)' \
            --field 'Derivation path:' 'ONLY IF YOU CUSTOMIZED IT' \
            --field 'Creation time:' "${today}" \
            --separator="${yad_field_sep}" \
            --image 'dialog-question' --window-icon='dialog-question' \
            --no-escape \
            --width=550 --borders=12)
    if [ -z "${dialog_output}" ]; then
        echo "Cancelling saving metadata for ${wallet_file}."
        return
    fi

    local electrum_version=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 1)
    local file_name=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 2)
    local wallet_type=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 3)
    local seed_type=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 4)
    local seed_phrase=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 5)
    local custom_words=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 6)
    local bip39=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 7)
    local script_type=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 8)
    local derivation_path=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 9)
    local created_time=$(${ECHO_CMD} -E "${dialog_output}" | ${CUT_CMD} -d $'\v' -f 10)

    echo ${electrum_version}
    echo ${file_name}
    echo ${wallet_type}
    echo ${seed_type}
    echo ${seed_phrase}
    echo ${custom_words}
    echo ${bip39}
    echo ${script_type}
    echo ${derivation_path}
    echo ${created_time}
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_do_save_metadata
fi
