# Configure backlight
echo "Configuring backlight"
copy etc/udev/rules.d/backlight.rules

# Install yay
if ! pacman -Qi yay > /dev/null; then
  echo "Installing yay"
  yaydir=$(mktemp -u)
  git clone https://aur.archlinux.org/yay.git "$yaydir"
  chmod 777 "$yaydir"
  pushd "$yaydir"
  sudo -u "$USERNAME" makepkg -si --noconfirm
  popd
fi

# Add multithreading support to makepkg
copy etc/makepkg.conf

# Install lightdm
pacman -S --needed --noconfirm --quiet lightdm
require_aur lightdm-slick-greeter
copy etc/lightdm/lightdm.conf
systemctl enable lightdm

# TODO: Install graphics drivers

################
# AUR Packages #
################

require_aur breeze-adapta-cursor-theme-git
require_aur i3lock-fancy-git
require_aur insync
require_aur snapd
require_aur vim-plug
#require_aur yq-bin

###########
# Cursors #
###########
echo "Checking cursor config"
copy usr/share/icons/default/index.theme

#######
# Git #
#######
echo "Checking git config"
sudo -u $USERNAME bash <<EOF
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL_ADDRESS"
git config --global core.excludesfile ~/.gitignore-global
EOF

#############
# Oh My Zsh #
#############
echo "Checking zsh config"
sudo -u $USERNAME bash <<'EOF'
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Setting up Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
#if [[ $SHELL != /bin/zsh ]]; then
#  chsh -s /bin/zsh
#fi
EOF

#################
# Snap Packages #
#################
echo "Snap config"
if ! systemctl is-active --quiet snapd.socket; then
  systemctl enable --now snapd.socket
fi
if [[ ! -h /snap ]]; then
  ln -s /var/lib/snapd/snap /snap
  echo "Snap needs to reboot your system. Ok? [y/n]: "
  read -n1 ans
  if [[ $ans =~ [Yy] ]]; then
    reboot
  else
    touch /tmp/REBOOT_REQUIRED
  fi
fi
if [[ ! -f /tmp/REBOOT_REQUIRED ]]; then
  snap_install goland --classic
  snap_install pycharm-community --classic
fi

echo "Script complete"
