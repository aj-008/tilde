#!/bin/sh
seq_file="$HOME/.cache/matugen/sequences"
for tty in /dev/pts/*; do
  [ -w "$tty" ] && cat "$seq_file" > "$tty" 2>/dev/null
done
