##############################
# PRE-INSTALLATION
##############################

# update base system
pacman -Syyu
pacman -S base base-devel

# sort mirrors
pacman -S reflector
reflector --verbose --country 'United States' -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

# set up grub
pacman -S grub
pacman -S linux linux-lts
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub \
  --boot-directory=/boot/EFI --recheck --debug
grub-mkconfig -o /boot/EFI/grub/grub.cfg
mkdir /boot/EFI/boot
cp /boot/EFI/grub/grubx64.efi /boot/EFI/boot/bootx64.efi

# color pacman output, add haskell-core repo, enable multilib repo
cp /etc/pacman.conf /etc/pacman.conf~
cat /etc/pacman.conf \
  | sed 's/#Color/Color/' \
#  | sed 's/\[extra\]/\[haskell-core\]\nServer = http:\/\/xsounds.org\/\~haskell\/core\/$arch\n\n\[extra\]/' \
  | sed 's/#\[multilib\]/\[multilib\]\nInclude = \/etc\/pacman\.d\/mirrorlist/' \
  > /tmp/pacman.conf
mv /tmp/pacman.conf /etc/

# initialize GPG keys, enable key signing, sign arch and haskell-core repo admin keys
pacman-key --init
mv /etc/pacman.d/gnupg/gpg.conf /etc/pacman.d/gnupg/gpg.conf~
#cat /etc/pacman.d/gnupg/gpg.conf \
#  | sed 's/hkp:\/\/pool\.sks-keyservers\.net/hkp:\/\/pgp\.mit\.edu:11371/' \
#  > /tmp/gpg.conf
#mv /tmp/gpg.conf /etc/pacman.d/gnupg/gpg.conf
pacman-key --populate archlinux
pacman-key -r 4209170B
pacman-key --lsign-key 4209170B
pacman-key --refresh-keys
pacman -Syy

# daemon to generate system entropy
pacman -S haveged
systemctl start haveged
systemctl enable haveged

##############################
# MAIN REPO PACKAGES
##############################

# basic tools
pacman -S sudo vim wget rsync openssh htop udevil keychain

# zsh
pacman -S zsh zsh-lovers zsh-completion

# python plus libraries
pacman -S \
  python python2 \
  python-numpy python2-numpy \
  python-matplotlib python2-matplotlib \
  python-sympy python2-sympy \
  python-scipy python2-scipy \
  ipython ipython2
  pypy3 pypy

# ghc and haskell utilities
pacman -S ghc alex happy haskell-haddock-library

# java
pacman -S jre8-openjdk

# xorg and related drivers
pacman -S xorg xorg-apps xf86-input-intel

# useful x utilities
pacman -S xcompmgr xdotool xclip

# window managers and desktop environments
pacman -S \
  haskell-xmonad haskell-xmonad-contrib \
  xfce4 xfce4-goodies kde kde-meta

# login manager
pacman -S slim slim-themes

# networking utilities
pacman -S wicd wicd-gtk network-manager-applet

# key management tool for gtk applications
pacman -S gnome-keyring

# install packages from arch repos
pacman -S \
  arandr pulseaudio pulseaudio-alsa pavucontrol \
  meld gparted \
  firefox vpnc icedtea-web \
  feh geeqie vlc mplayer smplayer gimp inkscape \
  lxappearance evince skype v4l2ucp wine acpi

# texlive and auctex
pacman -S texlive-most texlive-lang auctex

# emacs
pacman -S emacs emacs-python-mode emacs-haskell-mode

# libre office
pacman -S \
  libreoffice-still libreoffice-still-en-US hunspell-en \
  libreoffice-still-gnome libreoffice-still-kde4

# dictionary
pacman -S aspell-en

# install windows partition utilities
pacman -S dosfstools ntfs-3g

# network printer drivers
pacman -S cups hplip

# enable processor microcode with intel processors
# see arch wiki, as this requires some manual tweaking with grub
pacman -S intel-ucode

##############################
# AUR PACKAGES
##############################

# pacmatic and pacaur
pacman -S pacmatic
cd /tmp
wget http://aur.archlinux.org/packages/co/cower/cower.tar.gz
tar xvzf cower.tar.gz && cd cower
makepkg -s && pacman -U cower*.pkg.tar.xz
cd ..
wget http://aur.archlinux.org/packages/pa/pacaur/pacaur.tar.gz
tar xvzf pacaur && cd pacaur
makepkg -s && pacman -U pacaur*.pkg.tar.xz

# install packages from AUR
pacaur -S \
  google-chrome pamixer pulseaudio-ctl volnoti qbittorrent \
  ttf-ms-fonts ttf-oxygen ttf-droid ttf-liberation ttf-ubuntu-font-family \
  laptop-mode-tools orchis-gtk-theme-git

systemctl enable laptop-mode

##############################
# USER CONFIGURATION
##############################

# set keyboard layout and repeat delay/rate
loadkeys /usr/share/kbd/keymaps/i386/colemak/colemak.map.gz
localectl set-keymap colemak
localectl set-x11-keymap us,us pc105 colemak, \
  caps:backspace,shift:both_capslock,grp:alts_toggle
kbdrate -d 200 -r 60

# add user
useradd -m -g users -G wheesl,sys,lp,network,video,audio,storage,scannes,power -s /usr/bin/zsh perlinm

# set and synchronize system time
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
timedatectl set-ntp true

# uncomment to configure trackpoint
#echo -n 255 > /sys/devices/platform/i8042/serio1/serio2/speed
#echo -n 200 > /sys/devices/platform/i8042/serio1/serio2/sensitivity
#echo -n 10 > /sys/devices/platform/i8042/serio1/serio2/inertia

##############################
# DEFT DEPENDENCIES
##############################

pacman -S scons python2-markdown gnuplot haskell-hunit mlocate time valgrind

## notes ###
# add [infinality-bundle] to pacman.conf and install infinality-bundle