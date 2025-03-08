# rice-fields
my arch conifg

- for grub config place the tf2 folder in /boot/grub/themes then run

    ```sed -i 's/\/path\/to\/gfxtheme/\/boot\/grub\/themes\/tf2\/theme.txt/' /etc/default/grub```

    and then run ```grub-mkconfig -o /boot/grub/grub.cfg```

- .zshrc goes in home

- copy everything in  
    etc to /etc  
    .config to .config


- copy Candy/ to /usr/share/sddm/themes

- make sure to create these dirs
    - .config/zsh
    - .config/wget
    - .lang/rust