#!/bin/bash

echo "Updating apt repos in rootfs"
sed -e 's/http:\/\/ports\.ubuntu\.com\/ubuntu-ports\//http:\/\/turul.canonical.com\//g' \
 -e 's/deb http:\/\/turul.canonical.com\/ focal-backports /#deb http:\/\/turul.canonical.com\/ focal-backports /g' \
 -i /etc/apt/sources.list
#echo 'deb https://repo.download.nvidia.com/jetson/common r32.4 main
#deb https://repo.download.nvidia.com/jetson/t210 r32.4 main' > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
echo TEGRA_CHIPID 0x21 > /etc/nv_boot_control.conf
mkdir -p /opt/nvidia/l4t-packages/
touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall
echo "Done!"

echo "Installing desktop packages"
export DEBIAN_FRONTEND=noninteractive
apt update
yes | unminimize
apt install -y openssh-server systemd wget gnupg nano sudo linux-firmware less bsdutils locales curl \
 gnome-session gnome-session-wayland gnome-terminal gnome-initial-setup xxd ubuntu-desktop-minimal ||
(
 rm -rf /usr/share/dict/words.pre-dictionaries-common
 apt --fix-broken install
) # nicman23 says abracatabra ubuntu is shit
echo "Done!"

echo "Adding switchroot /nvidia key"
wget https://newrepo.switchroot.org/pubkey
apt-key add pubkey
rm pubkey
apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc
echo "Done!"


echo "Adding switchroot repo"
wget https://newrepo.switchroot.org/pool/unstable/s/switchroot-newrepo/switchroot-newrepo_1.1_all.deb
wget http://turul.canonical.com/pool/main/libf/libffi/libffi6_3.2.1-8_arm64.deb
dpkg -i switchroot-newrepo_1.1_all.deb libffi6_3.2.1-8_arm64.deb
rm switchroot-newrepo_1.1_all.deb libffi6_3.2.1-8_arm64.deb
echo 'force-overwrite' > /etc/dpkg/dpkg.cfg.d/sadface
apt update
apt dist-upgrade -y; apt install -y nintendo-switch-meta joycond
apt install -y nvidia-l4t-init nvidia-l4t-multimedia nvidia-l4t-oem-config \
 nvidia-l4t-3d-core nvidia-l4t-multimedia-utils nvidia-l4t-gstreamer \
 nvidia-l4t-firmware nvidia-l4t-xusb-firmware nvidia-l4t-configs \
 nvidia-l4t-tools nvidia-l4t-core nvidia-l4t-x11 nvidia-l4t-apt-source \
 nvidia-l4t-cuda nvidia-l4t-wayland
#rm /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall
echo "Done!"

echo "Making firstboot"
apt-get -y install --no-install-recommends oem-config-gtk/focal-updates
rm /etc/machine-id
echo "Done!"

echo "Fixing broken nvidia shit"
apt clean

mkdir -p /usr/share/alsa/ucm/tegra-s/
ln -s /usr/share/alsa/ucm/tegra-snd-t210ref-mobile-rt565x/HiFi /usr/share/alsa/ucm/tegra-s/HiFi
echo 'default-sample-rate = 48000' >> /etc/pulse/daemon.conf
sed 's/0660/0777/g' -i /etc/udev/rules.d/99-tegra-devices.rules
echo "Done!"

echo "Fix broken ubuntu shit"
sed 's/TimeoutStartSec=infinity/TimeoutStartSec=5/g' /usr/lib/systemd/system/systemd-time-wait-sync.service > /etc/systemd/system/systemd-time-wait-sync.service
sed '/\[Service\]/a\\TimeoutStartSec=10' -i /usr/lib/systemd/system/ssh.service
ln -fs /usr/lib/systemd/system/ssh.service /etc/systemd/system/sshd.service
ln -fs /dev/null /etc/systemd/system/ssh.service
echo "Done!"

echo installing alsa and friends
curl 'https://cdn.discordapp.com/attachments/697241533757390978/753597124859658400/debs.tar.xz' | unxz | tar xf -
dpkg -i `find debs -type f  | grep -v '\doc|\dbg|\dev\|equali'`
apt install -f -y
rm -rf debs
echo "Done!"
