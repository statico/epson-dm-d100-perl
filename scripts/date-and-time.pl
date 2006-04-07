#
# Relies on the main loop to run this script every second.
#
# Note that we don't clear the screen -- instead, write over the existing
# characters to prevent flicker.
#

print hide_cursor, move_home;
printf '%-40s', scalar localtime(time);
