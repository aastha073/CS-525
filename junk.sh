#!/bin/bash

# junk directory setup
readonly JUNK_DIR="${HOME}/.junk"

# Function to display usage message using heredoc
usage() {
    cat >&2 << EOF
Usage: $(basename "$0") [-hlp] [list of files]
  -h: Display help.
  -l: List junked files.
  -p: Purge all files.
  [list of files] with no other arguments to junk those files.
EOF
}

# variables
h_flag=0
l_flag=0
p_flag=0
flag_count=0

# Parsing command line options using getopts
while getopts ":hlp" opt; do
    case $opt in
        h)
            h_flag=1
            ((flag_count++))
            ;;
        l)
            l_flag=1
            ((flag_count++))
            ;;
        p)
            p_flag=1
            ((flag_count++))
            ;;
        \?)
            echo "Error: Unknown option '-$OPTARG'" >&2
            usage
            exit 1
            ;;
    esac
done

# Shift past the parsed options
shift $((OPTIND - 1))

# Check for too many options
if [ $flag_count -gt 1 ]; then
    echo "Error: Too many options enabled." >&2
    usage
    exit 1
fi

# Check if flags are specified along with files
if [ $flag_count -eq 1 ] && [ $# -gt 0 ]; then
    echo "Error: Too many options enabled." >&2
    usage
    exit 1
fi

# Create .junk directory if it doesn't exist
if [ ! -d "$JUNK_DIR" ]; then
    mkdir -p "$JUNK_DIR"
fi

# Handle the different operations
if [ $h_flag -eq 1 ] || [ $# -eq 0 ] && [ $flag_count -eq 0 ]; then
    # Display help
    usage
    exit 0
elif [ $l_flag -eq 1 ]; then
    # List files in junk directory
    ls -lAF "$JUNK_DIR"
    exit 0
elif [ $p_flag -eq 1 ]; then
    # Purge all files from junk directory
    rm -rf "${JUNK_DIR:?}"/*
    rm -rf "${JUNK_DIR:?}"/.[!.]*
    exit 0
else
    # Junk the specified files/directories
    error_occurred=0
    
    for item in "$@"; do
        if [ ! -e "$item" ]; then
            echo "Warning: '$item' not found." >&2
            error_occurred=1
        else
            # Move the item to junk directory (preserve just the basename)
            mv "$item" "$JUNK_DIR/$(basename "$item")"
        fi
    done
    
    if [ $error_occurred -eq 1 ]; then
        exit 1
    else
        exit 0
    fi
fi
