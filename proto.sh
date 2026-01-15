#! /usr/bin/bash

TARGET=/usr/local/bin
REMOVE="false"

while getopts ":r" opt; do
    case $opt in
        r) REMOVE="true" ;;
    esac
done

if [ $REMOVE == "true" ]; then
    if [ ! -e $TARGET/just ]; then
        echo "Nothing to remove"
    else
        echo "Removing 'just'"
        sudo rm $TARGET/just
        echo "Removed 'just' from $TARGET"
    fi
elif [ ! -e $TARGET/just ]; then
    echo "Installing 'just' to $TARGET..."
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to $TARGET
    just help
else 
    just help
fi
