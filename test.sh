grep -Pv '^\s*$|^\/\/' asdf.loc | while IFS= read -r line; do
    location=$(echo "$line" | cut -d',' -f1)
    location="${location%/}" # removes ending / if there is one
    file_name=$(echo "$line" | cut -d',' -f2)
    owner_group=$(echo "$line" | cut -d',' -f3)
    perms=$(echo "$line" | cut -d',' -f4)

    dir_name=$(echo "$location" | rev | cut -d/ -f1 | rev)
    echo $dir_name

done