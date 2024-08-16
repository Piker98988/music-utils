#! /bin/bash
# TODO: make reading the file_array var and printing it to stdout a function


# ran into problems while testing because this variables were not set. double check at the start from now on
if [ -z "$SONGS_DIR" ]; then
    # ask for path to a songs directory
    echo "The environment variable SONGS_DIR is not set."
    read -rep "Specify a default ABSOLUTE path for songs: " -i "$HOME/music/songs" songs_path
    # set songs directory environment var
    export SONGS_DIR=$songs_path
    
    # check if user wants to add to the ~/.bashrc file
    while true; do
        read -p "Add environment variables to ~/.bashrc? (y/n) " yn
        case $yn in
            [Yy]*)
                echo "export SONGS_DIR=$songs_path" >> "$HOME/.bashrc"
                echo "Added SONGS_DIR variable to ~/.bashrc"
                break;;
            [Nn]*) 
                echo "Variable not added. Note that for following executions this will not be set."
                break;;
                *) 
                echo "(y/n) ";;
        esac
    done
    # confirm to the user the path set
    echo "SONGS_DIR set to "$SONGS_DIR
else
    echo "Environment variable SONGS_DIR found: $SONGS_DIR"
fi

# check for PLAYLISTS_DIR var, if nonexistent assign it
if [ -z "$PLAYLISTS_DIR" ]; then
    # ask for a path to a playlists directory and set it
    echo "The environment variable PLAYLISTS_DIR is not set."
    read -rep "Specify a default ABSOLUTE path for playlists: " -i "$HOME/music/playlists" playlists_path
    export PLAYLISTS_DIR=$playlists_path
    
    # check if user wants to add it to ~/.bashrc
    while true; do
        read -p "Add environment variables to ~/.bashrc? (y/n)" yn
        case $yn in
            [Yy]*) 
                echo "Added environment variable to ~/.bashrc"
                echo "export PLAYLISTS_DIR=$playlists_path" >> "$HOME/.bashrc"
                break;;
            [Nn]*) 
                echo "Variable not added. Note that for following executions this will not be set."
                break;;
                *) echo "(y/n)";;
        esac
    done
    # confirm the set to the user
    echo "PLAYLISTS_DIR set to "$PLAYLISTS_DIR
else
    # if found echo the variable
    echo "Environment variable PLAYLISTS_DIR found: $PLAYLISTS_DIR"
fi


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

# ask for files to be moved to a playlist
while true; do
    read -rp "Would you like all of the music files to be copied to a playlist? (y/n) " yn
    case $yn in
        [Yy]*) break;; # continue runtime
        [Nn]*)
            # feedback for user
            echo "Moving successful. Files moved:"
            for file in ${file_array[@]}
            do
                echo $file
                # remove the copied files to music directory from the origin directory
                rm "$file"
            done
            exit;; # end execution because following code is to add to a playlist folder
            *) echo "(y/n)";;
    esac
done

# list available playlists from $PLAYLISTS_DIR and ask for a playlist to move to
echo "Available playlists in the default directory:"
ls -l "$PLAYLISTS_DIR"
read -rep "Select a playlist: " playlist


# move files from the origin dir to the target playlist dir
# as we copied the files before instead of moving them, there is no need to copy again, we can move them there
for file in ${file_array[@]}
do
    echo    # new line
    mv "$file" "$PLAYLISTS_DIR/$playlist"
    echo "file $file has been succesfully moved to the playlist: $playlist inside the playlist directory $PLAYLISTS_DIR."
done

# round-up
echo
echo "Operation successful. Files moved: "

# print files interacted with for feedback
for file in ${file_array[@]}
do
    echo "$file"
done
