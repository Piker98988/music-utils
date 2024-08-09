#! /bin/bash

while True; do
  read -rep "Would you like for this script to be run inside a python virtual environment? [y/N] " YNvenv
  case $YNvenv in
    ["Yy"]*)
      read -rep "Where would you like for your environment to be located?\n> " venvdir
      echo "Creating virtual environment at $venvdir ..."
      python -m venv "$venvdir"
      echo "Sourcing virtual environment..."
      source "$venvdir"
      echo "Installing dependencies locally... "
      pip install -r ./util-downloader/dependencies.txt || echo "Error installing dependencies. Check your python installation."; exit
      ;;
    ["Nn"]*)
      echo "Installing dependencies globally... "
      pip install -r ./util-downloader/dependencies.txt || echo "Error while installing dependencies. Check your python installation."; exit
      ;;
    *)
      echo;;
  esac
done

# running downloader -> wish you luck!!








# exit 0 -> cancelled by user
# exit 1 -> run successfully
# exit 2 -> error renaming
