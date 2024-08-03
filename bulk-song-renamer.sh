#!/usr/bin/env bash

# TODO:
# There is no functionality to specify the renaming pattern.
# The first to words from the filename will be removed.


# read the files to rename
read -rep "Files to rename: " -i '*' files_string

# Create an array from the input string
readarray -t file_array <<< $files_string

# Print the array to verify
echo "Files to bulk rename:"
for file in ${file_array[@]}
do
    echo $file
done

while true; do
    read -p "Start the renaming proccess for the aforementioned files? (y/n)" yn
    case $yn in
        [Yy]*) echo "Renaming start... "; break;;
        [Nn]*) echo "Renaming cancelled. Exiting..."; exit;;
            *) echo "(y/n)";;
    esac
done

# start the renaming proccess
for file in ${file_array[@]}
do
    echo;
    new_filename=$(echo $file | sed 's/^[^ ]* [^ ]* //')
    echo $file"  ---->  "$new_filename
    mv "$file" "$new_filename"
    echo $file" renamed"
done

echo;
ls -l