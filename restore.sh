#!/bin/bash

# Usage: ./restore_rice.sh /path/to/backup_dir

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <backup_directory>"
  exit 1
fi

backup_dir="$1"

if [ ! -d "$backup_dir" ]; then
  echo "Backup directory $backup_dir does not exist or is not a directory."
  exit 1
fi

echo "Restoring rice backup from $backup_dir"

# Restore files inside home directory backup
echo "Restoring files from home directory backup..."
shopt -s globstar nullglob

# Copy files from backup_dir excluding root_backup
for file in "$backup_dir"/**; do
  # Skip if directory
  [ -d "$file" ] && continue

  # Skip files inside root_backup (will restore separately)
  if [[ "$file" == "$backup_dir/root_backup/"* ]]; then
    continue
  fi

  # Compute relative path based on backup_dir
  rel_path="${file#$backup_dir/}"
  dest_path="$HOME/$rel_path"

  # Create destination directory if needed
  mkdir -p "$(dirname "$dest_path")"

  # Copy file
  cp -r "$file" "$dest_path"
  echo "Restored $dest_path"
done

# Restore files outside home directory
root_backup_dir="$backup_dir/root_backup"

if [ -d "$root_backup_dir" ]; then
  echo "Restoring files outside home directory..."

  # Copy files back to their absolute locations
  for file in "$root_backup_dir"/**; do
    [ -d "$file" ] && continue

    # Get relative path inside root_backup
    rel_path="${file#$root_backup_dir/}"
    dest_path="/$rel_path"

    # Need sudo if destination requires root permissions
    sudo mkdir -p "$(dirname "$dest_path")"
    sudo cp -r "$file" "$dest_path"
    echo "Restored $dest_path"
  done
else
  echo "No files outside home directory to restore."
fi

echo "Restore completed."
