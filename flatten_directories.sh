#!/bin/bash

# Flatten directories

set -e

NEXPECTED_ARGS=1
USAGE="$(basename "$0") [-h] [-v] <directory> [-r <regex>]

    -h  display this help and exit
    -d  remove empty directories after running
    -e  Regex pattern
    -v  verbose

Flatten directories."


cleanup=false
verbose=false
unset opts
while getopts 'hde:v' OPTION; do
    case "$OPTION" in
        h) 
            echo "$USAGE"
            exit 0
            ;;
        d)
            cleanup_dirs=true
            ;;
        e)
            opts=( -regex "$OPTARG" )
            ;;
        v)
            verbose=true
            ;;
        ?) 
            echo "$USAGE"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND -1))"


if [ ! $# -eq $NEXPECTED_ARGS ]; then
    echo "Expect $NEXPECTED_ARGS args, received $# args"
    echo "$USAGE"
    exit 1
fi


target_directory=$1
if [ ! -d "$target_directory" ]; then
    echo "$target_directory: No such file or directory"
    exit 1
fi


if [ "$verbose" = true ]; then
    echo "Running $(basename "$0")"
fi


# Flatten all subdirectories into target directory
find "$target_directory" -mindepth 2 -type f "${opts[@]}" | while read filepath;
do
    temp_filepath_1="${filepath//$target_directory\//}"
    temp_filepath_2="${temp_filepath_1//\//_}"
    new_filepath="$target_directory/$temp_filepath_2"

    if [ "$verbose" = true ]; then
        echo "Moving $filepath to $new_filepath"
    fi

    mv "$filepath" "${new_filepath}"
done


# Remove empty directories
if [ "$cleanup_dirs" = true ]; then
    find "$target_directory" -mindepth 1 -type d -empty -delete
fi
