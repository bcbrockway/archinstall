# Install

copy etc/X11/xorg.conf.d/00-keyboard.conf
copy etc/X11/xorg.conf.d/30-touchpad.conf

# Install lightdm
pacman -S --needed --noconfirm --quiet lightdm
require_aur lightdm-slick-greeter
copy etc/lightdm/lightdm.conf
systemctl enable lightdm
