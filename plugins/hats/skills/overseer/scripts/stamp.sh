#!/bin/sh
# Append one entry to the watch log, stamped with the clock's time, never a typed one.
#   stamp.sh LOGFILE "what happened"
# Set TZ (for example TZ=Europe/London) to stamp in the user's time zone.
[ $# -ge 2 ] || { echo "usage: stamp.sh LOGFILE TEXT..." >&2; exit 2; }
log=$1; shift
printf -- '- %s: %s\n' "$(date +%H:%M)" "$*" >> "$log"
