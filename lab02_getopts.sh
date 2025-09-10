#!/bin/sh
# lab02_getopts.sh


valid_count=0     # how many valid flags we've seen
valid_flag=""     # first valid flag (h, l, p)
unknown_opt=""    # if any unknown option seen

# Parse options
while getopts ":hlp" opt; do
  case "$opt" in
    h|l|p)
      if [ "$valid_count" -eq 0 ]; then
        valid_flag="$opt"
      fi
      valid_count=$((valid_count + 1))
      ;;
    \?)
      unknown_opt="$OPTARG"
      ;;
    :)
      unknown_opt="$OPTARG"
      ;;
  esac
done

shift $((OPTIND - 1))
args="$*"

# Decide mode
if [ -n "$unknown_opt" ]; then
  mode="unknown"
elif [ "$valid_count" -ge 2 ]; then
  mode="duplicate"
elif [ "$valid_count" -eq 1 ]; then
  case "$valid_flag" in
    h) mode="help" ;;
    l) mode="list" ;;
    p) mode="purge" ;;
  esac
else
  if [ -z "$args" ]; then
    mode="help"
  else
    mode="junk"
  fi
fi

# Output
if [ "$mode" = "junk" ]; then
  echo "junk: $args"
else
  if [ -n "$args" ]; then
    echo "$mode: unexpected $args"
  else
    echo "$mode"
  fi
fi