#!/bin/bash

# Usage: ./backup_rice.sh backup_paths.txt /path/to/backup/dir

# Check arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <paths_file> <backup_destination>"
  exit 1
fi

paths_file="$1"
backup_root="$2"

# Timestamp for unique backup folder
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="${backup_root}/rice_backup_${timestamp}"

mkdir -p "$backup_dir"

echo "Backing up files listed in $paths_file to $backup_dir"

# Read paths file line by line
while IFS= read -r path; do
  # Skip empty lines or comments
  [[ -z "$path" || "$path" =~ ^# ]] && continue
  
  # Expand ~ to home directory
  expanded_path=$(eval echo "$path")

  if [ -e "$expanded_path" ]; then
    # Get relative path from home directory if path is inside home
    if [[ "$expanded_path" == "$HOME"* ]]; then
      rel_path="${expanded_path#$HOME/}"
      dest_path="$backup_dir/$rel_path"
      mkdir -p "$(dirname "$dest_path")"
      cp -r "$expanded_path" "$dest_path"
      echo "Copied $expanded_path -> $dest_path"
    else
      # For paths outside home, copy preserving absolute path (danger: needs root if outside access)
      abs_path="${expanded_path#/}"
      dest_path="$backup_dir/root_backup/$abs_path"
      mkdir -p "$(dirname "$dest_path")"
      cp -r "$expanded_path" "$dest_path"
      echo "Copied $expanded_path -> $dest_path"
    fi
  else
    echo "Warning: $expanded_path does not exist, skipping."
  fi
done < "$paths_file"

echo "Backup completed."

# Optional: create a tar.gz archive of the backup folder
tarball="${backup_dir}.tar.gz"
tar -czf "$tarball" -C "$backup_root" "$(basename "$backup_dir")"
echo "Compressed backup saved to $tarball"
