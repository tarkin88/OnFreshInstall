#!/bin/bash	


if [[ -f `pwd`/variables ]]; then
  source variables
else
  echo "missing file: variables"
  exit 1
fi

print_title "Welcome to OFI [On Fresh Install] script by Tarkin88 V0.1"
print_warning "ALERT! \n This script just run on Manjaro, ArchLinux and Antergos" 
print_line
print_info "Your Architecture is $ARCHI."

check_root

check_connection

check_pacman_blocked

echo "Do you want to add powerpill repo?"
read -p "Press y for accept" OPTION_XYNE
if [[ $OPTION_XYNE -eq y ]]; then

	echo "Adding Xyne Repo (For Powerpill)"

	add_line  "\n[xyne-$ARCHI]
 	#A repo for Xyne's own projects: http://xyne.archlinux.ca/projects/
 	#Packages for the "$ARCHI" architecture.
 	#Note that this includes all packages in [xyne-any].
	SigLevel = Required
	Server = http://xyne.archlinux.ca/repos/xyne" >> /etc/pacman.conf
	
	system_update

	package_install "powerpill"
fi
system_update

package_install "git base-devel ccache"

 replace_line '#Color Color' /etc/pacman.conf
 replace_line '#TotalDownload TotalDownload' /etc/pacman.conf
 replace_line '#VerbosePkgLists VerbosePkgLists' /etc/pacman.conf
 add_line "ILoveCandy" "/etc/pacman.conf"

select_user
git clone https://github.com/helmuthdu/dotfiles
cp dotfiles/.bashrc dotfiles/.dircolors dotfiles/.dircolors_256 dotfiles/.nanorc dotfiles/.yaourtrc ~/
cp dotfiles/.bashrc dotfiles/.dircolors dotfiles/.dircolors_256 dotfiles/.nanorc dotfiles/.yaourtrc /home/${username}/
rm -fr dotfiles
echo "Do you want to Reconfigure the system?"
read -p "Press y for accept" OPTION_RECONF
if [[ $OPTION_RECONF -eq y ]]; then
	reconfigure_system
fi
chown -R ${username}:users /home/${username}

package_install "bc rsync mlocate bash-completion pkgstats ntp"
is_package_installed "ntp" && ntpd -u ntp:ntp
package_install "zip unzip unrar p7zip lzop cpio"
package_install "avahi nss-mdns"
is_package_installed "avahi" && system_ctl enable avahi-daemon
package_install "alsa-utils alsa-plugins"
[[ ${ARCHI} == x86_64 ]] && package_install "lib32-alsa-plugins"
package_install "pulseaudio pulseaudio-alsa pavucontrol"
[[ ${ARCHI} == x86_64 ]] && package_install "lib32-libpulse"
package_install "ntfs-3g dosfstools exfat-utils f2fs-tools fuse fuse-exfat autofs"
is_package_installed "fuse" && add_module "fuse"
package_install "nfs-utils"
system_ctl enable rpcbind
system_ctl enable nfs-client.target
system_ctl enable remote-fs.target
system_ctl enable systemd-readahead-collect
system_ctl enable systemd-readahead-replay
package_install "tlp"
system_ctl enable tlp
system_ctl enable tlp-sleep
system_ctl mask systemd-rfkill
tlp start
package_install "openbox obconf yaourt terminus-font xfce4-panel nitrogen lxappearance-obconf clipit networkmanager dnsmasq network-manager-applet"
package_install "pcmanfm gvfs gvfs-mtp android-udev arandr mpd mpc ncmpcpp dunst libmtp xfce4-whiskermenu-plugin"
package_install "obmenu menumaker slim obkey volumeicon chromium rxvt-unicode scrot htop gparted ranger xarchiver-gtk2"
package_install "xdg-user-dirs wxgtk2.8 viewnior galculator firefox firefox-i18n-es-mx flashplugin gksu polkit-gnome"
package_install "ttf-bitstream-vera ttf-dejavu youtube-dl compton"
package_install "gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"
package_install "gstreamer0.10 gstreamer0.10-plugins"
package_install "vlc libbluray libquicktime libdvdread libdvdnav libdvdcss cdrdao gmrun"
install_xorg

install_video_cards

system_ctl enable slim 
system_ctl enable accounts-daemon
system_ctl enable NetworkManager

mkdir -p /home/${username}/.config/openbox/
mkdir -p ~/.compose-cache
# Improvements
touch /etc/sysctl.d/99-sysctl.conf
add_line "fs.inotify.max_user_watches = 524288" "/etc/sysctl.d/99-sysctl.conf"
cp /etc/xdg/openbox/{menu.xml,rc.xml,autostart} /home/${username}/.config/openbox/
chown -R ${username}:users /home/${username}/.config
#config xinitrc
add_line  "setxkbmap latam &" "/home/${username}/.config/openbox/autostart"
add_line  "nitroge --restore &" "/home/${username}/.config/openbox/autostart"
add_line  "xfce4-panel" "/home/${username}/.config/openbox/autostart"
add_line  "(sleep 3s clipit) &" "/home/${username}/.config/openbox/autostart"
add_line  "(sleep 3s nm-applet) &" "/home/${username}/.config/openbox/autostart"
add_line  "(sleep 3s volumeicon)" "/home/${username}/.config/openbox/autostart"

touch /home/${username}/.xinitrc
echo "exec dbus-launch openbox-session" > /home/${username}/.xinitrc
aur_package_install "sublime-text-dev chromium-pepper-flash"
aur_package_install "qbittorrent ttf-monaco"
is_package_installed "fontconfig" && pacman -Rdds freetype2 fontconfig cairo
aur_package_install "freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu"
xdg-user-dirs-update
clean_orphan_packages
finish