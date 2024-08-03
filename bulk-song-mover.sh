#! /bin/bash

# ask for files to be moved
read -rep "Files to move: " -i '*' files_string

# Create an array from the input string
readarray -t file_array <<< $files_string

# Print the array to verify
echo "Files to bulk move to the default music directory: (SONGS_DIR env var)"

for file in ${file_array[@]}
do
    echo $file
done

# double check for confirmation of user
while true; do
    read -p "Start the moving proccess for the aforementioned files? (y/n)" yn
    case $yn in
        [Yy]*) echo "Moving start... "; break;;
        [Nn]*) echo "Moving cancelled. Exiting..."; exit;;
            *) echo "(y/n)";;
    esac
done

# start the moving proccess
for file in ${file_array[@]}
do
    echo
    cp "$file" "$SONGS_DIR"
    echo "file "$file" has been succesfully moved to the default music directory."
done

# ask for files to be moved to a playlist, else, print the songs copied to $SONGS_DIR and remove the files from origin directory
while true; do
    read -rp "Would you like all of the music files to be moved to a playlist? (y/n) " yn
    case $yn in
        [Yy]*) break;;
        [Nn]*)
            # TODO: unclutter whatever is going on here
            echo "Moving successful. Files moved:"
            for file in ${file_array[@]}
            do
                echo $file
                rm "$file"
            done
            exit;;
            *) echo "(y/n)";;
    esac
done

# list available playlists from $PLAYLISTS_DIR and ask for a playlist to move to
echo "Available playlists in the PLAYLISTS_DIR env var:"
ls -l "$PLAYLISTS_DIR"
read -rep "Select a playlist from the default playlist directory: " playlist


# move files from the origin dir to the target playlist dir
for file in ${file_array[@]}
do
    echo
    mv "$file" "$PLAYLISTS_DIR/$playlist"
    echo "file $file has been succesfully moved to the playlist: $playlist inside the playlist directory $PLAYLISTS_DIR."
done

# round-up
echo
echo "Operation successful. Files moved: "

for file in ${file_array[@]}
do
    echo $file
done
