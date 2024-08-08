#!/usr/bin/env bash

# read the files to rename
read -rep "Song files to rename: " -i '*' files_string

# Create an array from the input string
readarray -t file_array <<< $files_string

# Print the array to verify
echo "Files to bulk rename:"

for file in ${file_array[@]}
do
    new_filename="${file//"spotifydown.com - "/""}"
    new_filename="${new_filename//" "/"_"}"
    echo "$file  ---->  $new_filename"
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
    new_filename="${file//"spotifydown.com - "/""}"
    new_filename="${new_filename//" "/"_"}"
    mv "$file" "$new_filename"
    echo $file" renamed"
done

# print out the renamed files
echo;
ls -l