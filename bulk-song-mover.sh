#! /bin/bash
: "
# move song
echo "moving '$1' to music dir /mnt/dev150G/music/songs"
mv "$1" /mnt/dev150G/music/songs

# add to a playlist
ls -l /mnt/dev150G/music/playlists
read -e -p "select a playlist: " -i "change" playlist
cp /mnt/dev150G/music/songs/"$1" /mnt/dev150G/music/playlists/"$playlist"

printf "\n"
# print directory so user knows it has been moved
cd /mnt/dev150G/music/playlists/"$playlist" || exit
pwd
ls -ahl | grep "$1"


cd /mnt/dev150G/music/songs || exit
pwd
ls -ahl | grep "$1"

echo "complete."
"


read -rep "Files to move: " -i '*' files_string

# Create an array from the input string
readarray -t file_array <<< $files_string

# Print the array to verify
echo "Files to bulk move to the default music directory: (SONGS_DIR env var)"
# shellcheck disable=SC2068
for file in ${file_array[@]}
do
    echo $file
done

while true; do
    read -p "Start the moving proccess for the aforementioned files? (y/n)" yn
    case $yn in
        [Yy]*) echo "Moving start... "; break;;
        [Nn]*) echo "Moving cancelled. Exiting..."; exit;;
            *) echo "(y/n)";;
    esac
done

# start the moving proccess
# shellcheck disable=SC2068
for file in ${file_array[@]}
do
    echo;
#    new_filename=$(echo $file | sed 's/^[^ ]* [^ ]* //')
#    echo $file"  ---->  "$new_filename
#    mv "$file" "$new_filename"
#    echo $file" renamed"
    cp $file $SONGS_DIR
    echo "file "$file" has been succesfully moved to the default music directory."
done

# ask for files to be moved to a playlist, else, print files copied to $SONGS_DIR and remove the files from origin directory

while true; do
    read -p "Would you like all of the music files to be moved to a playlist? (y/n) " yn
    case $yn in
        [Yy]*) break;;
        [Nn]*)
            echo "Moving successful. Files moved:"
            # shellcheck disable=SC2068
            for file in ${file_array[@]}
            do
                echo $file
                rm $file
            done
            exit;;
            *) echo "(y/n)";;
    esac
done

# list available playlists from $PLAYLISTS_DIR and ask for a playlist to move to
ls -l $PLAYLISTS_DIR
read -ep "select a playlist from the default playlist directory: " playlist

# shellcheck disable=SC2068
for file in ${file_array[@]}
do
    echo;
#    new_filename=$(echo $file | sed 's/^[^ ]* [^ ]* //')
#    echo $file"  ---->  "$new_filename
#    mv "$file" "$new_filename"
#    echo $file" renamed"
    mv $file "$PLAYLISTS_DIR/$playlist"
    echo "file "$file" has been succesfully moved to the selected playlist $playlist inside the default playlist directory $PLAYLISTS_DIR."
done

# Exit the script printing files moved
echo;
echo "Operation successful. Files moved: "

# shellcheck disable=SC2068
for file in ${file_array[@]}
do
    # shellcheck disable=SC2086
    echo $file
done
