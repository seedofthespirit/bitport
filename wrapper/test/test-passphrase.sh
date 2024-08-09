#!/bin/bash

script_path=$(/usr/bin/realpath "$0")
script_name=$(/usr/bin/basename "$0")
script_dir=$(/usr/bin/dirname "${script_path}")
source "${script_dir}/common-utils"

main() {
    local logging_window="test passphrase for LUKS encrypted volume"
    setup_logging_coproc "${logging_window}"

    test_1
    #test_2

    #test_create_container
    #test_luks_format

    #test_luks_add_passphrase
}

test_1() {
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

test_2() {
    local text1 text2 text3 text4 text5 text6 text7 text8 text9 text10
    local passphrase_ref
    text1='<b>We are going to create a LUKS encrypted filesystem.\n\n'
    text2='The next dialog will ask for the LUKS volume passphrase.\n'
    text3='You can switch between show/hide passphrase in the Pinentry dialog by\n'
    text4='pressing the button next to the passphrase box.</b>\n\n'
    text5='<b>Passphrase suggestion</b>:\n'
    text6='One of the ways to generate strong passphrases is to use /usr/bin/diceware\n'
    text7='See\n'
    text8='  http://world.std.com/~reinhold/diceware.html\n'
    text9='  https://blogs.dropbox.com/tech/2012/04/zxcvbn-realistic-password-strength-estimation/\n'
    text10="\n<b><span foreground='mediumblue'>(*) Remember to securely save your passphrase in multiple safe places!</span></b>\n"

    luks_passphrase_with_confirm "${text1}${text2}${text3}${text4}${text5}${text6}${text7}${text8}${text9}${text10}" passphrase_ref
    echo "passphrase_ref: ${passphrase_ref}"
    if [ "${passphrase_ref}" = '' ]; then
        echo "test_2() passphrase_ref: ${passphrase_ref}"
        fatal "No passphrase was given. Exiting."
    fi
}


# rewrite of luks_passphrase_double_check()
luks_passphrase_with_confirm() {
    local ui_text="$1"
    declare -n passphrase_ref1="$2"  # nameref of the variable used in the caller.
    # Function:
    # Present a Pinentry dialog for a new passphrase.
    # The user can cancel the dialog to stop the whole process.

    log_info "Prompting the user for a new LUKS passphrase."

    local passphrase_title='LUKS Volume Encrytion Passphrase'
    local status

    ${YAD_CMD} \
        --title "${passphrase_title}" \
        --text "${ui_text}" \
        --button 'OK:0' --button='Cancel:1' --no-escape \
        --image 'dialog-information' --window-icon 'dialog-information' \
        --center --fixed --borders=12
    status="$?"
    if [ "${status}" != '0' ]; then
        fatal "User canceled inputting the new passphrase."
    fi

    #echo 'proceeding to pinentry..'

    local response
    response=$(${ECHO_CMD} -e "SETTITLE New LUKS passphrase\nSETDESC Enter your new LUKS passphrase and its confirmation.\nSETPROMPT Passphrase:\nSETREPEAT Confirm:      \nGETPIN\n" | ${PINENTRY_CMD})

    passphrase_ref1=$(${ECHO_CMD} "${response}" | ${SED_CMD} -nr '0,/^D (.+)/s//\1/p')

    local error
    error=$(${ECHO_CMD} "${response}" | ${GREP_CMD} -E 'Operation cancelled')
    if [ ! -z "${error}" ]; then
        log_error "${PINENTRY_CMD} dialog for new passphrase was cancelled; ${error}"
    else
        log_info "New LUKS passphrase was given via ${PINENTRY_CMD}"
    fi
}

luks_passphrase() {
    local ui_text="$1"
    declare -n passphrase_ref3="$2"  # nameref of the variable used in the caller.
    # Function:
    # Present a dialog for an existing passphrase.

    log_info "Prompting the user for the LUKS passphrase."
    local passphrase_title='LUKS Volume Encrytion Passphrase'

    ${YAD_CMD} \
        --title "${passphrase_title}" \
        --text "${ui_text}" \
        --button='Ok:0' --no-escape \
        --image 'dialog-information' --window-icon='dialog-information' \
        --center --fixed --borders=12

    ##PINENTRY_CMD='/usr/bin/pinentry-gtk-2'  # already defined in linux-commands

    local response
    response=$(${ECHO_CMD} -e "SETTITLE LUKS passphrase\nSETDESC Enter your LUKS passphrase.\nSETPROMPT Passphrase:\nGETPIN\n" | ${PINENTRY_CMD})
    passphrase_ref3=$(${ECHO_CMD} "${response}" | ${SED_CMD} -nr '0,/^D (.+)/s//\1/p')

    local error
    error=$(${ECHO_CMD} "${response}" | ${GREP_CMD} -E 'Operation cancelled')
    if [ ! -z "${error}" ]; then
        log_error "${PINENTRY_CMD} dialog for the passphrase was cancelled; ${error}"
    else
        log_info "LUKS passphrase was given via ${PINENTRY_CMD}"
    fi
}

test_create_container() {
    local mount_point='/tmp'
    local container_file_path='/tmp/container.fs'

    create_container "${mount_point}" "${container_file_path}"

}

test_luks_format() {
    local container_file_path='/tmp/container.fs'
    local passphrase
    luks_format "${container_file_path}" passphrase
}

test_luks_add_passphrase() {
    local container_file_path='/tmp/container.fs'

    luks_add_passphrase "${container_file_path}"
}

luks_add_passphrase() {
    local container_file="$1"

    local text1 text2 text3 text4 text5 text6 text7 text8 text9
    text1="<b>We are going to add a new passphrase for the LUKS volume on\n${container_file}.</b>\n\n"
    text2='<b>The next dialog will ask for one of the current passphrases for permission.</b>\n'
    text3='<b>You can switch between show/hide passphrase in the Pinentry dialog by\n'
    text4='pressing the button next to the passphrase box.</b>'
    local existing_passphrase

    luks_passphrase "${text1}${text2}${text3}${text4}" existing_passphrase

    echo "${existing_passphrase}"
    if [ -z "${existing_passphrase}" ]; then
        fatal "Old passphrase was not given. Exiting."
    fi

    text1='<b>The next dialog will ask for the new LUKS passphrase.</b>\n\n'
    text2='<b>You can switch between show/hide passphrase in the Pinentry dialog by\n'
    text3='pressing the button next to the passphrase box.</b>\n\n'
    text4='<b><span foreground="blue">Remember to keep your passphrase in multiple safe locations!</span></b>\n\n'
    text5='<b>Passphrase suggestion</b>:\n'
    text6='One of the ways to generate strong passphrases is to use /usr/bin/diceware\n'
    text7='See\n'
    text8='http://world.std.com/~reinhold/diceware.html\n'
    text9='https://blogs.dropbox.com/tech/2012/04/zxcvbn-realistic-password-strength-estimation/'
    local new_passphrase

    luks_passphrase_with_confirm "${text1}${text2}${text3}${text4}${text5}${text6}${text7}${text8}${text9}" new_passphrase

    if [ -z "${new_passphrase}" ]; then
        fatal "New passphrase was not given. Exiting."
    fi

    # cryptsetup luksAddKey restriction:
    # We need to supply cryptsetup luksAddKey with both the existing passphrase and the new passphrase,
    # but only one of them can be given via stdin and the other has to be given via a file.
    # Writing the passphrase to a file is less secure in general but in our case it should be good
    # becaseu we are using a live linux system.
    local status
    local existing_passphrase_file
    existing_passphrase_file=$(${MKTEMP_CMD})
    status="$?"
    if [ "${status}" != '0' ]; then
        exit 1
    fi
    ${ECHO_CMD} -En "${existing_passphrase}" > "${existing_passphrase_file}"

    log_info "Adding a new passphrase for the LUKS volume."
    local output
    output=$( ${ECHO_CMD} -En "${new_passphrase}" | ${SUDO_CMD} ${CRYPTSETUP_CMD} luksAddKey "${container_file}" --key-file="${existing_passphrase_file}" --new-keyfile=- 2>&1 )
    status="$?"

    ${RM_CMD} "${existing_passphrase_file}"

    if [ "${status}" = '0' ]; then
        log_info "Successfully added the new passphrase for the LUKS volume."
    elif [ "${status}" = '1' ]; then
        fatal "sudo failed running cryptsetup luksAddKey ${container_file}."
    else
        text1="cryptsetup luksAddKey failed in adding a new passphrase; ${output}\n"
        local pass_error='No key available with this passphrase.'
        if [ "${output}" = "${pass_error}" ]; then
            text2="This error message means the existing passphrase was wrong.\n"
            fatal "${text1}${text2}"
        else
            fatal "${text1}"
        fi
    fi
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
