#!/bin/sh
cat /etc/shells
clear
echo "Hello, $USER"
echo "Today's date is `date`, this is week `date +"%V"`."
echo "This is `uname -s` running on a `uname -m` processor."
echo "This is the uptime information:"
uptime
echo
echo "That's all folks!"