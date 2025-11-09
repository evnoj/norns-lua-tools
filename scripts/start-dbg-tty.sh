#!/bin/sh

screen -dmS dbg sleep infinity
sleep 0.5
screen -S dbg -X bindkey "\003" detach
dbg_pid=$(screen -ls | grep dbg | awk '{print $1}' | awk -F '.' '{print $1}')
dbg_ppid=$(pgrep -P $dbg_pid)
tty=$(readlink /proc/$dbg_ppid/fd/0)
# echo "$pty" > /tmp/dbg_pty
ln -s "$tty" /tmp/dbg_tty
