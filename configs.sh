#!/bin/bash

#add way to clone repos and build if needed

# Check if the script is run by root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run by root' >&2
    exit 1
fi

# Process the configs.loc file
grep -Pv '^\s*$|^\/\/' configs.loc | while IFS= read -r line; do
    location=$(echo "$line" | cut -d',' -f1)
    location="${location%/}" # removes ending / if there is one
    file_name=$(echo "$line" | cut -d',' -f2)
    owner_group=$(echo "$line" | cut -d',' -f3)
    perms=$(echo "$line" | cut -d',' -f4)

    if [ -n "$location" ] && [ ! -n "$file_name" ]; then
        if [ ! -d "$location" ]; then
            mkdir -p "$location"
        fi
        continue
    else if [ -n "$location" ] && [ ! -n "$file_name" ]; then
    fi

    # Create the directory if it doesn't exist
    if [ ! -d "$location" ]; then
        mkdir -p "$location"
    fi

    # Check if the file exists in the configs directory
    if [ -e "configs/$file_name" ]; then
        # If the file already exists in the destination, move it and copy the new one
        if [ -e "$location/$file_name" ]; then
            mv "$location/$file_name" "$location/$file_name.old"
            cp "configs/$file_name" "$location/$file_name"
        else
            cp "configs/$file_name" "$location/$file_name"
        fi
    else
        # If the file doesn't exist in the configs directory, output an error message
        echo "$file_name does not exist in the ./configs directory"
    fi

    # If owner/group and permissions are specified, set them
    if [ -n "$owner_group" ] && [ -n "$perms" ]; then
        chmod "$perms" "$location"
        chmod "$perms" "$location/$file_name"

        chown "$owner_group" "$location"
        chown "$owner_group" "$location/$file_name"
    fi

done
