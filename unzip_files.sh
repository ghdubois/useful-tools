#!/bin/bash

# Check if unzip is installed, install it if not
if ! command -v unzip &> /dev/null
then
    echo "unzip could not be found, installing..."
    sudo apt-get update
    sudo apt-get install unzip
fi

# Iterate through all .zip files in the current directory and unzip them
for file in *.zip
do
    echo "Unzipping $file..."
    unzip "$file"
done

echo "All files unzipped."
