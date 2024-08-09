#!/bin/bash

script_path=$(/usr/bin/realpath "$0")
script_name=$(/usr/bin/basename "$0")
script_dir=$(/usr/bin/dirname "${script_path}")
source "${script_dir}/common-utils"

main() {
    local logging_window="test passphrase for LUKS encrypted volume"
    setup_logging_coproc "${logging_window}"

    #test_find_installed_electrum
    #test_check_electrum
    #test_check_storage_mount
    #test_mkdir_data_dir
    #test_create_container
    #test_load_dm_crypt
    #test_luks_format
    #test_luks_open
    #test_luks_mkfs
    #test_luks_mount
    #test_luks_create_top_dir
    #test_luks_umount
    #test_luks_close

    #test_luks_passphrase_with_confirm
    test_luks_passphrase

}

test_find_installed_electrum() {
    local electrum_version
    find_installed_electrum "${ELECTRUM_DIR}" electrum_version
    if [ -z "${electrum_version}" ]; then
        fatal "error: can't find a unique Electrum installation under ${ELECTRUM_DIR}"
    fi
}

test_check_electrum() {
    log_info "Checking if electrum is running."
    check_electrum
}

test_check_storage_mount() {
    check_storage_mount "${WALLET_STORAGE_MOUNT_POINT}"
}

test_mkdir_data_dir() {
    local storage_data_directory_path="/tmp${WALLET_STORAGE_MOUNT_POINT}/${STORAGE_WALLET_DIRECTORY}"
    echo "${storage_data_directory_path}"
    mkdir_data_dir "${storage_data_directory_path}"
}

test_create_container() {
    local container_file_path="/tmp${WALLET_STORAGE_MOUNT_POINT}/${WALLET_CONTAINER_FILE}"
    echo "${WALLET_STORAGE_MOUNT_POINT}"
    echo "${container_file_path}"
    create_container "/tmp${WALLET_STORAGE_MOUNT_POINT}" "${container_file_path}"
}

test_load_dm_crypt() {
    load_dm_crypt
}

test_luks_format() {
    local passphrase
    container_file_path='/tmp/media/user/EDATA/electrum/electrum_data.fs'
    luks_format "${container_file_path}" passphrase
    echo "passphrase: ${passphrase}"
}

test_luks_open() {
    local passphrase
    container_file_path='/tmp/media/user/EDATA/electrum/electrum_data.fs'
    echo "LUKS_WALLET_DEVICE_NAME: ${LUKS_WALLET_DEVICE_NAME}"
    luks_open "${container_file_path}" "${LUKS_WALLET_DEVICE_NAME}" passphrase
}

test_luks_mkfs() {
    luks_mkfs "${LUKS_WALLET_DEVICE_NAME}"
}

test_luks_mount() {
    echo "${LUKS_WALLET_DEVICE_NAME}"
    local mount_point="/tmp${LUKS_WALLET_MOUNT_POINT}"
    echo "${mount_point}"
    mkdir -p "${mount_point}"
    luks_mount "${LUKS_WALLET_DEVICE_NAME}" "${mount_point}"
}

test_luks_create_top_dir() {
    local mount_point="/tmp${LUKS_WALLET_MOUNT_POINT}"
    luks_create_top_dir "${mount_point}" "${LUKS_ELECTRUM_DATA_DIR}"
    luks_create_top_dir "${mount_point}" "${LUKS_WALLET_METADATA_DIR}"
}

test_luks_umount() {
    local mount_point="/tmp${LUKS_WALLET_MOUNT_POINT}"
    luks_umount "${mount_point}"
}

test_luks_close() {
    luks_close "${LUKS_WALLET_DEVICE_NAME}"
}


test_save_metadata_new_wallets() {
    :
}


test_luks_passphrase_with_confirm() {
    local text1 text2 text3 text4 text5 text6 text7 text8 text9
    local passphrase_ref
    text1='<b>We are going to create a LUKS encrypted filesystem.</b>\n\n'
    text2='<b>The next dialog will ask for the LUKS volume passphrase.\n'
    text3='You can switch between show/hide passphrase in the Pinentry dialog\n'
    text4='by pressing the button to the right of the passphrase box.</b>\n\n'
    text5='<b>Passphrase suggestion</b>:\n'
    text5='One of the ways to generate strong passphrases is to use /usr/bin/diceware\n'
    text6='See\n'
    text7='  http://world.std.com/~reinhold/diceware.html\n'
    text8='  https://blogs.dropbox.com/tech/2012/04/zxcvbn-realistic-password-strength-estimation/\n'
    text9="\n<b><span foreground='mediumblue'>(*) Remember to securely save your passphrase in multiple safe places!</span></b>\n"

    luks_passphrase_with_confirm "${text1}${text2}${text3}${text4}${text5}${text6}${text7}${text8}${text9}" passphrase_ref
    echo "passphrase_ref: ${passphrase_ref}"
    if [ "${passphrase_ref}" = '' ]; then
        echo "test_2() passphrase_ref: ${passphrase_ref}"
        fatal "No passphrase was given. Exiting."
    fi
}

test_luks_passphrase() {
    local text1 text2 text3
    local output
    local container_file='container_file'
    text1="<b>We are going to open the LUKS encrypted filesystem on\n${container_file}.\n"
    text2='The next dialog will ask for its LUKS volume passphrase.\n</b>'
    #text3='Do you want to have the passphrase hidden or shown as you type?'
    local passphrase_ref2
    luks_passphrase "${text1}${text2}" passphrase_ref2
    if [ "${passphrase_ref2}" = '' ]; then
        fatal "No passphrase was given. Exiting."
    fi
    echo "passphrase_ref2: ${passphrase_ref2}"
}



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
