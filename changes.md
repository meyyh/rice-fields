### udev rule !not working
udev rule to auto mount things to /mnt /etc/udev/rules.d/99-custom-rules.conf or something

### cron job ro run reflector
installed cronie and made reflector run at 4am daily  
/etc/crontab
```
00 09-18  * * * reflector --country US --latest 30 -f 10 --save /etc/pacman.d/mirrorlist
```

### custom colors in vscodium
changed c++ syntax colors in vscodium settings.json

### github ssh keys
added ssh keys to github  
gened with ssh-keygen -t ed25519 -C "cooperrs123@gmail.com"  
added
```
Host github.com
	Hostname ssh.github.com
	Port 443
	User git
```
to ~/.ssh/config to make git clone work over https as the school blocks ssh
