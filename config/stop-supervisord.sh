#!/bin/sh

# If one of Supervisord's children dies (or exits, for whatever reason), this
# script will tell supervisord to quit by sending SIGQUIT (kill -3) to it.

echo "Started supervisord event listener" >&2;

# the next line is part of supervisord protocol, do not change it!
printf "READY\n";

while read line; do
  echo "Processing Supervisord Event: $line" >&2;
  kill -SIGQUIT $PPID
done < /dev/stdin
