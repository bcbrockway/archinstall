# Arch Installer

## Instructions

```bash
### Boot into the live CD

### Connect to the internet
ip link set wlp58s0 up
wpa_supplicant -B -i wlp58s0 -c <(wpa_passphrase XXXXX XXXXX)
dhcpcd wlp58s0

### Update /etc/pacman.d/mirrorlist and download git
vim /etc/pacman.d/mirrorlist
pacman -Sy git

### Download this repo and run the script
git clone https://github.com/bcbrockway/archinstall.git
cd archinstall

### Check values in settings.env
vim settings.env

### Run install script
./install.sh
```
