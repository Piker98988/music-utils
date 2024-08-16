#! /bin/bash

#while True; do
#  read -rep "Would you like for this script to be run inside a python virtual environment? [y/N] " YNvenv
#  case $YNvenv in
#    ["Yy"]*)
#      while True; do
#        read -rep "Where would you like for your environment to be located?\n> " venvdir
#        if [ -d $venvdir ]; then
#          echo "Directory exists."
#        else
#          True
#        fi
#      done
#
#      echo "Creating virtual environment at $venvdir ..."
#      python -m venv "$venvdir"
#      echo "Sourcing virtual environment..."
#      source $venvdir"/bin/activate"
#      echo "Installing dependencies locally... "
#      pip install -r ./util-downloader/dependencies.txt || echo "Error installing dependencies. Check your python installation." && exit 1
#      echo "export DEPS_INSTALLED_music-utils=True"
#      ;;
#    ["Nn"]*)
#      echo "Installing dependencies globally... "
#      pip install -r ./util-downloader/dependencies.txt || echo "Error while installing dependencies. Check your python installation." && exit 1
#      echo "export DEPS_INSTALLED_music-utils=True"
#      ;;
#    *)
#      echo "Checking for dependencies..."
#      pip list | grep "playwright"
#      echo;;
#  esac
#done
verbosity=0
dependency_check=true
ask_for_operation=true

while getopts ":hcf:psvd:mr" opt; do
  case $opt in
    h)
      echo "Usage: $0 [flag]

      --- flags ---
      -h -> show this help
      -c -> skip dependency check
      -f [file] -> provide a file to operate with
      -p -> only usable with operation download; download playlist
      -s -> only usable with operation download; download song
      -v -> enable verboser logging for each v (-vv, -vvv, -vvvv...) maximum 4

      --- operations ---
      combine flags to make multiple operations to the same set of files, if none provided, you will be prompted.
      -d [url] -> download a playlist or song from spotify
      -m -> move a set of files to the default songs or playlists dir
      -r -> rename in bulk given files (automatically done after download)"
      exit 0
      ;;
    d)
      ask_for_operation=false
      ;;
    m)
      ask_for_operation=false
      ;;
    r)
      ask_for_operation=false
      ;;
    v)
      # shellcheck disable=SC2071
      if [ $verbosity -le 4 ]; then
        verbosity=$((verbosity + 1))
      else
        echo "Verbosity level too high. Use the -h flag for reference"
        exit 1
      fi
      ;;
    c)
      dependency_check=false
      ;;
    f)
      files_to_use_string=$OPTARG
      ;;
    p)
      multiple=true
      ;;
    s)
      multiple=false
      ;;
    \?)
      echo "Invalid option: -$opt"
      exit 1
      ;;
  esac
done

# TODO clean up mess with file input
# ask for files to be moved
read -rep "Files to move: " -i '*' files_to_use_string

# Create an array from the input string
readarray -t file_array <<< $files_to_use_string

# Print the array to verify
echo "Files to bulk move to the default music directory: (SONGS_DIR env var)"

for file in ${file_array[@]}
do
    echo $file
done

shift $((OPTIND - 1))

# TODO logging verbosity levels
verbose_0_log () {
  if [ $verbosity -ge 1 ]; then

    true
  fi
}

verbose_1_log () {
  if $verbosity; then
    echo "debug | $1"
  fi
}

verbose_2_log () {
  echo "critical | $1"
}

# if the flag -d is provided skip dep check
if [ $dependency_check ]; then
  # python is completely needed
  { which python >/dev/null 2>&1; echo "Dependency found: python"; } || { echo "dependency not found! 'python'"; exit 2; }

  # same for pip in case packages are needed
  { which pip >/dev/null 2>&1; echo "Dependency found: pip"; } || { echo "dependency not found! 'pip'"; exit 2; }

  # check if its installed globally
  { pip list | grep -q "^playwright\s"; echo "Dependency found: python-playwright"; } || { echo "dependency not found! 'python-playwright'"; missing_deps=true; }

  # check if its installed globally
  { pip list | grep -q "^loguru\s"; echo "Dependency found: python-loguru"; } || { echo "dependency not found! 'python-loguru'"; missing_deps=true; }


  if [ $missing_deps ]; then
    while True; do
      read -rep "Do you want to install missing dependencies? (y/n) " yn
      case $yn in
      ["Yy"]*)
        pip install -r ./util-downloader/requirements.txt
        break
        ;;
      ["Nn"]*)
        echo "Missing dependencies. Aborting-"
        exit 2
        ;;
      *)
        echo "(y/n) "
        ;;
      esac
    done
  fi
  echo "All dependencies are installed!"
fi


download=false
move=false
rename=false
while true; do
  if [ $ask_for_operation ]; then
    read -rep "Operations to make: (d/m/r separated by spaces) " operations
  fi

  for char in $operations; do
    case "$char" in
      d)
        download=true
        echo "download"
        ;;
      m)
        move=true
        echo "moving"
        ;;
      r)
        rename=true
        echo "renaming"
        ;;
      *)
        echo "What is '$char'? Input a valid operation in a valid syntax."
        download=false
        rename=false
        move=false
        break
        ;;
    esac
  done
done



