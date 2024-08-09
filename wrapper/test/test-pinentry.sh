#!/bin/bash

PINENTRY_CMD='/usr/bin/pinentry-gtk-2'   # pinentry-gtk2 locks windows, provides show/hide button; best
#PINENTRY_CMD='/usr/bin/pinentry-gnome3'  # pinentry-gnome3 locks windows, has no show/hide button; poor
#PINENTRY_CMD='/usr/bin/pinentry-qt'      # pinentry-qt doesn't lock windows, has no show/hide button; poor
#PINENTRY_CMD='/usr/bin/pinentry-fltk'    # pinentry-fltk doesn't lock windows, has no repeat; has no show/hide button; bad
#PINENTRY_CMD='/usr/bin/pinentry-x2go'     # pinentry-x2go numerals only; bad
ECHO_CMD='/bin/echo'
GREP_CMD='/bin/grep'
SED_CMD='/bin/sed'

# SETTITLE: Window title
# SETDESC: descriptive text in the dialog
# SETPROMPT: text left to the password box
# SETREPEAT: double confirmation
# GETPIN: Prompt for the password
# 
# 
response=$(${ECHO_CMD} -e "SETTITLE New LUKS passphrase\nSETDESC Enter your new LUKS passphrase and its confirmation.\nSETPROMPT Passphrase:\nSETREPEAT Confirm:      \nGETPIN\n" | ${PINENTRY_CMD})
status="$?"
echo "response: ${response}"
passphrase_ref1=$( ${ECHO_CMD} "${response}" | ${SED_CMD} -nr '0,/^D (.+)/s//\1/p')
error=$(${ECHO_CMD} "${response}" | ${GREP_CMD} -E 'Operation cancelled')

echo "status: $status"
echo "passphrase_ref1: $passphrase_ref1"
echo "error: $error"
