#!/usr/bin/env bash

# old comments. the direction of the script was to rename whatever to whatever but the direction has changed. only to rename music.
echo "bulk rename songs to remove the 'spotifydown.com - ' part"

# read the files to rename
read -rep "Song files to rename: " -i '*' files_string

# Create an array from the input string
readarray -t file_array <<< $files_string

# Print the array to verify
echo "Files to bulk rename:"
# shellcheck disable=SC2068
for file in ${file_array[@]}
do
    new_filename="${file//"spotifydown.com - "/""/}"
    echo $file"  ---->  "$new_filename
done

# double check confirmation
while true; do
    read -p "Start the renaming proccess for the aforementioned files? (y/n)" yn
    case $yn in
        [Yy]*) echo "Renaming start... "; break;;
        [Nn]*) echo "Renaming cancelled. Aborting."; exit;;
            *) echo "(y/n)";;
    esac
done

# start the renaming proccess
for file in ${file_array[@]}
do
    echo;
    new_filename="${file//"spotifydown.com - "/""/}"
    echo $file"  ---->  "$new_filename
    mv "$file" "$new_filename"
    echo $file" renamed"
done

# print out the renamed files
echo;
ls -l