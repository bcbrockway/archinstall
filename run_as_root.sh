# Install lightdm
pacman -S --needed --noconfirm --quiet lightdm
require_aur lightdm-slick-greeter
cp etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
systemctl enable lightdm

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
