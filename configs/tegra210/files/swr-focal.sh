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
 gnome-session gnome-session-wayland gnome-terminal gnome-initial-setup ubuntu-desktop-minimal ||
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
cat << EOF > /etc/systemd/system/upower.service
[Unit]
Description=Daemon for power management
Documentation=man:upowerd(8)

[Service]
Type=dbus
BusName=org.freedesktop.UPower
ExecStart=/usr/lib/upower/upowerd
Restart=on-failure

# Filesystem lockdown
ProtectSystem=strict
# Needed by keyboard backlight support
ProtectKernelTunables=false
ProtectControlGroups=true
ReadWritePaths=/var/lib/upower
StateDirectory=upower
ProtectHome=true
PrivateTmp=true

# Network
# PrivateNetwork=true would block udev's netlink socket
IPAddressDeny=any
RestrictAddressFamilies=AF_UNIX AF_NETLINK

# Execute Mappings
MemoryDenyWriteExecute=true

# Modules
ProtectKernelModules=true

# Real-time
RestrictRealtime=true

# Privilege escalation
NoNewPrivileges=true

# Capabilities
CapabilityBoundingSet=

# System call interfaces
LockPersonality=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service
SystemCallFilter=ioprio_get

# Namespaces
PrivateUsers=no
RestrictNamespaces=no

# Locked memory
LimitMEMLOCK=0

[Install]
WantedBy=graphical.target
EOF

cat << EOF > /lib/firmware/brcm/brcmfmac4356-pcie.txt
NVRAMRev=662895
sromrev=11
boardrev=0x1250
boardtype=0x074a
boardflags=0x02400001
boardflags2=0xc0802000
boardflags3=0x00000108
macaddr=98:b6:e9:53:50:a3
ccode=0
regrev=0
antswitch=0
pdgain5g=4
pdgain2g=4
muxenab=0x10
wowl_gpio=0
wowl_gpiopol=0
swctrlmap_2g=0x11411141,0x42124212,0x10401040,0x00211212,0x000000ff
swctrlmap_5g=0x42124212,0x41114111,0x42124212,0x00211212,0x000000cf
swctrlmapext_2g=0x00000000,0x00000000,0x00000000,0x000000,0x003
swctrlmapext_5g=0x00000000,0x00000000,0x00000000,0x000000,0x003
phycal_tempdelta=50
papdtempcomp_tempdelta=20
fastpapdgainctrl=1
olpc_thresh=0
lowpowerrange2g=0
tworangetssi2g=1
lowpowerrange5g=0
tworangetssi5g=1
ed_thresh2g=-75
ed_thresh5g=-75
eu_edthresh2g=-75
eu_edthresh5g=-75
paprdis=0
femctrl=10
vendid=0x14e4
devid=0x43ec
manfid=0x2d0
nocrc=1
otpimagesize=502
xtalfreq=37400
rxchain=3
txchain=3
aa2g=3
aa5g=3
agbg0=2
agbg1=2
aga0=2
aga1=2
tssipos2g=1
extpagain2g=2
tssipos5g=1
extpagain5g=2
tempthresh=255
tempoffset=255
rawtempsense=0x1ff
pa2ga0=-181,5872,-700
pa2ga1=-180,6148,-728
pa2ga2=-193,3535,-495
pa2ga3=-201,3608,-499
pa5ga0=-189,5900,-717,-190,5874,-715,-189,5921,-718,-194,5812,-708
pa5ga1=-194,5925,-724,-196,5852,-718,-189,5858,-712,-196,5767,-707
pa5ga2=-187,3550,-504,-176,3713,-526,-189,3597,-505,-192,3532,-496
pa5ga3=-187,3567,-507,-187,3543,-506,-181,3589,-512,-187,3582,-508
subband5gver=0x4
pdoffsetcckma0=0x2
pdoffsetcckma1=0x2
pdoffset40ma0=0x3344
pdoffset80ma0=0x1133
pdoffset40ma1=0x3344
pdoffset80ma1=0x1133
maxp2ga0=76
maxp5ga0=74,74,74,74
maxp2ga1=76
maxp5ga1=74,74,74,74
cckbw202gpo=0x0000
cckbw20ul2gpo=0x0000
mcsbw202gpo=0x99644422
mcsbw402gpo=0x99644422
dot11agofdmhrbw202gpo=0x6666
ofdmlrbw202gpo=0x0022
mcsbw205glpo=0x88766663
mcsbw405glpo=0x88666663
mcsbw805glpo=0xbb666665
mcsbw205gmpo=0xd8666663
mcsbw405gmpo=0x88666663
mcsbw805gmpo=0xcc666665
mcsbw205ghpo=0xdc666663
mcsbw405ghpo=0xaa666663
mcsbw805ghpo=0xdd666665
mcslr5glpo=0x0000
mcslr5gmpo=0x0000
mcslr5ghpo=0x0000
sb20in40hrpo=0x0
sb20in80and160hr5glpo=0x0
sb40and80hr5glpo=0x0
sb20in80and160hr5gmpo=0x0
sb40and80hr5gmpo=0x0
sb20in80and160hr5ghpo=0x0
sb40and80hr5ghpo=0x0
sb20in40lrpo=0x0
sb20in80and160lr5glpo=0x0
sb40and80lr5glpo=0x0
sb20in80and160lr5gmpo=0x0
sb40and80lr5gmpo=0x0
sb20in80and160lr5ghpo=0x0
sb40and80lr5ghpo=0x0
dot11agduphrpo=0x0
dot11agduplrpo=0x0
temps_period=15
temps_hysteresis=15
rssicorrnorm_c0=4,4
rssicorrnorm_c1=4,4
rssicorrnorm5g_c0=1,1,3,1,1,2,1,1,2,1,1,2
rssicorrnorm5g_c1=3,3,4,3,3,4,3,3,4,2,2,3
initxidx2g=20
initxidx5g=20
btc_params84=0x8
btc_params95=0x0
btcdyn_flags=0x3
btcdyn_dflt_dsns_level=99
btcdyn_low_dsns_level=0
btcdyn_mid_dsns_level=22
btcdyn_high_dsns_level=24
btcdyn_default_btc_mode=5
btcdyn_btrssi_hyster=5
btcdyn_dsns_rows=1
btcdyn_dsns_row0=5,-120,0,-52,-72

EOF

cat << EOF > /var/lib/alsa/asound.state
state.tegrahda {
	control.1 {
		iface CARD
		name 'HDMI/DP,pcm=3 Jack'
		value true
		comment {
			access read
			type BOOLEAN
			count 1
		}
	}
	control.2 {
		iface MIXER
		name 'd IEC958 Playback Con Mask'
		value '0fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access read
			type IEC958
			count 1
		}
	}
	control.3 {
		iface MIXER
		name 'd IEC958 Playback Pro Mask'
		value '0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access read
			type IEC958
			count 1
		}
	}
	control.4 {
		iface MIXER
		name 'd IEC958 Playback Default'
		value '0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type IEC958
			count 1
		}
	}
	control.5 {
		iface MIXER
		name 'd IEC958 Playback Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.6 {
		iface MIXER
		name 'd HDA Decode Capability'
		value 0
		comment {
			access read
			type INTEGER
			count 1
			range '0 - 4294967295'
		}
	}
	control.7 {
		iface MIXER
		name 'd HDA Maximum PCM Channels'
		value 2
		comment {
			access read
			type INTEGER
			count 1
			range '0 - 4294967295'
		}
	}
	control.8 {
		iface MIXER
		name 'd HDA Comfort Noise'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.9 {
		iface PCM
		device 3
		name 'd ELD'
		value '100008006b1400011000000000000000ee034c2d53796e634d61737465720009070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read volatile'
			type BYTES
			count 95
		}
	}
	control.11 {
		iface PCM
		device 3
		name 'Playback Channel Map'
		value.0 0
		value.1 0
		value.2 0
		value.3 0
		value.4 0
		value.5 0
		value.6 0
		value.7 0
		comment {
			access 'read write'
			type INTEGER
			count 8
			range '0 - 36'
		}
	}
}
state.tegrasndt210ref {
	control.1 {
		iface MIXER
		name 'AMX1 Byte Map 0'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.2 {
		iface MIXER
		name 'AMX1 Byte Map 1'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.3 {
		iface MIXER
		name 'AMX1 Byte Map 2'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.4 {
		iface MIXER
		name 'AMX1 Byte Map 3'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.5 {
		iface MIXER
		name 'AMX1 Byte Map 4'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.6 {
		iface MIXER
		name 'AMX1 Byte Map 5'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.7 {
		iface MIXER
		name 'AMX1 Byte Map 6'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.8 {
		iface MIXER
		name 'AMX1 Byte Map 7'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.9 {
		iface MIXER
		name 'AMX1 Byte Map 8'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.10 {
		iface MIXER
		name 'AMX1 Byte Map 9'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.11 {
		iface MIXER
		name 'AMX1 Byte Map 10'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.12 {
		iface MIXER
		name 'AMX1 Byte Map 11'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.13 {
		iface MIXER
		name 'AMX1 Byte Map 12'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.14 {
		iface MIXER
		name 'AMX1 Byte Map 13'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.15 {
		iface MIXER
		name 'AMX1 Byte Map 14'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.16 {
		iface MIXER
		name 'AMX1 Byte Map 15'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.17 {
		iface MIXER
		name 'AMX1 Byte Map 16'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.18 {
		iface MIXER
		name 'AMX1 Byte Map 17'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.19 {
		iface MIXER
		name 'AMX1 Byte Map 18'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.20 {
		iface MIXER
		name 'AMX1 Byte Map 19'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.21 {
		iface MIXER
		name 'AMX1 Byte Map 20'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.22 {
		iface MIXER
		name 'AMX1 Byte Map 21'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.23 {
		iface MIXER
		name 'AMX1 Byte Map 22'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.24 {
		iface MIXER
		name 'AMX1 Byte Map 23'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.25 {
		iface MIXER
		name 'AMX1 Byte Map 24'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.26 {
		iface MIXER
		name 'AMX1 Byte Map 25'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.27 {
		iface MIXER
		name 'AMX1 Byte Map 26'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.28 {
		iface MIXER
		name 'AMX1 Byte Map 27'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.29 {
		iface MIXER
		name 'AMX1 Byte Map 28'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.30 {
		iface MIXER
		name 'AMX1 Byte Map 29'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.31 {
		iface MIXER
		name 'AMX1 Byte Map 30'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.32 {
		iface MIXER
		name 'AMX1 Byte Map 31'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.33 {
		iface MIXER
		name 'AMX1 Byte Map 32'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.34 {
		iface MIXER
		name 'AMX1 Byte Map 33'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.35 {
		iface MIXER
		name 'AMX1 Byte Map 34'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.36 {
		iface MIXER
		name 'AMX1 Byte Map 35'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.37 {
		iface MIXER
		name 'AMX1 Byte Map 36'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.38 {
		iface MIXER
		name 'AMX1 Byte Map 37'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.39 {
		iface MIXER
		name 'AMX1 Byte Map 38'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.40 {
		iface MIXER
		name 'AMX1 Byte Map 39'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.41 {
		iface MIXER
		name 'AMX1 Byte Map 40'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.42 {
		iface MIXER
		name 'AMX1 Byte Map 41'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.43 {
		iface MIXER
		name 'AMX1 Byte Map 42'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.44 {
		iface MIXER
		name 'AMX1 Byte Map 43'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.45 {
		iface MIXER
		name 'AMX1 Byte Map 44'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.46 {
		iface MIXER
		name 'AMX1 Byte Map 45'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.47 {
		iface MIXER
		name 'AMX1 Byte Map 46'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.48 {
		iface MIXER
		name 'AMX1 Byte Map 47'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.49 {
		iface MIXER
		name 'AMX1 Byte Map 48'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.50 {
		iface MIXER
		name 'AMX1 Byte Map 49'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.51 {
		iface MIXER
		name 'AMX1 Byte Map 50'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.52 {
		iface MIXER
		name 'AMX1 Byte Map 51'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.53 {
		iface MIXER
		name 'AMX1 Byte Map 52'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.54 {
		iface MIXER
		name 'AMX1 Byte Map 53'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.55 {
		iface MIXER
		name 'AMX1 Byte Map 54'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.56 {
		iface MIXER
		name 'AMX1 Byte Map 55'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.57 {
		iface MIXER
		name 'AMX1 Byte Map 56'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.58 {
		iface MIXER
		name 'AMX1 Byte Map 57'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.59 {
		iface MIXER
		name 'AMX1 Byte Map 58'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.60 {
		iface MIXER
		name 'AMX1 Byte Map 59'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.61 {
		iface MIXER
		name 'AMX1 Byte Map 60'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.62 {
		iface MIXER
		name 'AMX1 Byte Map 61'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.63 {
		iface MIXER
		name 'AMX1 Byte Map 62'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.64 {
		iface MIXER
		name 'AMX1 Byte Map 63'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.65 {
		iface MIXER
		name 'AMX1 Output Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.66 {
		iface MIXER
		name 'AMX1 Input1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.67 {
		iface MIXER
		name 'AMX1 Input2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.68 {
		iface MIXER
		name 'AMX1 Input3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.69 {
		iface MIXER
		name 'AMX1 Input4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.70 {
		iface MIXER
		name 'AMX2 Byte Map 0'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.71 {
		iface MIXER
		name 'AMX2 Byte Map 1'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.72 {
		iface MIXER
		name 'AMX2 Byte Map 2'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.73 {
		iface MIXER
		name 'AMX2 Byte Map 3'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.74 {
		iface MIXER
		name 'AMX2 Byte Map 4'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.75 {
		iface MIXER
		name 'AMX2 Byte Map 5'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.76 {
		iface MIXER
		name 'AMX2 Byte Map 6'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.77 {
		iface MIXER
		name 'AMX2 Byte Map 7'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.78 {
		iface MIXER
		name 'AMX2 Byte Map 8'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.79 {
		iface MIXER
		name 'AMX2 Byte Map 9'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.80 {
		iface MIXER
		name 'AMX2 Byte Map 10'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.81 {
		iface MIXER
		name 'AMX2 Byte Map 11'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.82 {
		iface MIXER
		name 'AMX2 Byte Map 12'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.83 {
		iface MIXER
		name 'AMX2 Byte Map 13'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.84 {
		iface MIXER
		name 'AMX2 Byte Map 14'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.85 {
		iface MIXER
		name 'AMX2 Byte Map 15'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.86 {
		iface MIXER
		name 'AMX2 Byte Map 16'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.87 {
		iface MIXER
		name 'AMX2 Byte Map 17'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.88 {
		iface MIXER
		name 'AMX2 Byte Map 18'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.89 {
		iface MIXER
		name 'AMX2 Byte Map 19'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.90 {
		iface MIXER
		name 'AMX2 Byte Map 20'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.91 {
		iface MIXER
		name 'AMX2 Byte Map 21'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.92 {
		iface MIXER
		name 'AMX2 Byte Map 22'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.93 {
		iface MIXER
		name 'AMX2 Byte Map 23'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.94 {
		iface MIXER
		name 'AMX2 Byte Map 24'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.95 {
		iface MIXER
		name 'AMX2 Byte Map 25'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.96 {
		iface MIXER
		name 'AMX2 Byte Map 26'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.97 {
		iface MIXER
		name 'AMX2 Byte Map 27'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.98 {
		iface MIXER
		name 'AMX2 Byte Map 28'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.99 {
		iface MIXER
		name 'AMX2 Byte Map 29'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.100 {
		iface MIXER
		name 'AMX2 Byte Map 30'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.101 {
		iface MIXER
		name 'AMX2 Byte Map 31'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.102 {
		iface MIXER
		name 'AMX2 Byte Map 32'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.103 {
		iface MIXER
		name 'AMX2 Byte Map 33'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.104 {
		iface MIXER
		name 'AMX2 Byte Map 34'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.105 {
		iface MIXER
		name 'AMX2 Byte Map 35'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.106 {
		iface MIXER
		name 'AMX2 Byte Map 36'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.107 {
		iface MIXER
		name 'AMX2 Byte Map 37'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.108 {
		iface MIXER
		name 'AMX2 Byte Map 38'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.109 {
		iface MIXER
		name 'AMX2 Byte Map 39'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.110 {
		iface MIXER
		name 'AMX2 Byte Map 40'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.111 {
		iface MIXER
		name 'AMX2 Byte Map 41'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.112 {
		iface MIXER
		name 'AMX2 Byte Map 42'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.113 {
		iface MIXER
		name 'AMX2 Byte Map 43'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.114 {
		iface MIXER
		name 'AMX2 Byte Map 44'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.115 {
		iface MIXER
		name 'AMX2 Byte Map 45'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.116 {
		iface MIXER
		name 'AMX2 Byte Map 46'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.117 {
		iface MIXER
		name 'AMX2 Byte Map 47'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.118 {
		iface MIXER
		name 'AMX2 Byte Map 48'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.119 {
		iface MIXER
		name 'AMX2 Byte Map 49'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.120 {
		iface MIXER
		name 'AMX2 Byte Map 50'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.121 {
		iface MIXER
		name 'AMX2 Byte Map 51'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.122 {
		iface MIXER
		name 'AMX2 Byte Map 52'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.123 {
		iface MIXER
		name 'AMX2 Byte Map 53'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.124 {
		iface MIXER
		name 'AMX2 Byte Map 54'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.125 {
		iface MIXER
		name 'AMX2 Byte Map 55'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.126 {
		iface MIXER
		name 'AMX2 Byte Map 56'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.127 {
		iface MIXER
		name 'AMX2 Byte Map 57'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.128 {
		iface MIXER
		name 'AMX2 Byte Map 58'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.129 {
		iface MIXER
		name 'AMX2 Byte Map 59'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.130 {
		iface MIXER
		name 'AMX2 Byte Map 60'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.131 {
		iface MIXER
		name 'AMX2 Byte Map 61'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.132 {
		iface MIXER
		name 'AMX2 Byte Map 62'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.133 {
		iface MIXER
		name 'AMX2 Byte Map 63'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.134 {
		iface MIXER
		name 'AMX2 Output Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.135 {
		iface MIXER
		name 'AMX2 Input1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.136 {
		iface MIXER
		name 'AMX2 Input2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.137 {
		iface MIXER
		name 'AMX2 Input3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.138 {
		iface MIXER
		name 'AMX2 Input4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.139 {
		iface MIXER
		name 'ADX1 Byte Map 0'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.140 {
		iface MIXER
		name 'ADX1 Byte Map 1'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.141 {
		iface MIXER
		name 'ADX1 Byte Map 2'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.142 {
		iface MIXER
		name 'ADX1 Byte Map 3'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.143 {
		iface MIXER
		name 'ADX1 Byte Map 4'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.144 {
		iface MIXER
		name 'ADX1 Byte Map 5'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.145 {
		iface MIXER
		name 'ADX1 Byte Map 6'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.146 {
		iface MIXER
		name 'ADX1 Byte Map 7'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.147 {
		iface MIXER
		name 'ADX1 Byte Map 8'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.148 {
		iface MIXER
		name 'ADX1 Byte Map 9'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.149 {
		iface MIXER
		name 'ADX1 Byte Map 10'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.150 {
		iface MIXER
		name 'ADX1 Byte Map 11'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.151 {
		iface MIXER
		name 'ADX1 Byte Map 12'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.152 {
		iface MIXER
		name 'ADX1 Byte Map 13'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.153 {
		iface MIXER
		name 'ADX1 Byte Map 14'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.154 {
		iface MIXER
		name 'ADX1 Byte Map 15'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.155 {
		iface MIXER
		name 'ADX1 Byte Map 16'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.156 {
		iface MIXER
		name 'ADX1 Byte Map 17'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.157 {
		iface MIXER
		name 'ADX1 Byte Map 18'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.158 {
		iface MIXER
		name 'ADX1 Byte Map 19'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.159 {
		iface MIXER
		name 'ADX1 Byte Map 20'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.160 {
		iface MIXER
		name 'ADX1 Byte Map 21'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.161 {
		iface MIXER
		name 'ADX1 Byte Map 22'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.162 {
		iface MIXER
		name 'ADX1 Byte Map 23'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.163 {
		iface MIXER
		name 'ADX1 Byte Map 24'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.164 {
		iface MIXER
		name 'ADX1 Byte Map 25'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.165 {
		iface MIXER
		name 'ADX1 Byte Map 26'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.166 {
		iface MIXER
		name 'ADX1 Byte Map 27'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.167 {
		iface MIXER
		name 'ADX1 Byte Map 28'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.168 {
		iface MIXER
		name 'ADX1 Byte Map 29'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.169 {
		iface MIXER
		name 'ADX1 Byte Map 30'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.170 {
		iface MIXER
		name 'ADX1 Byte Map 31'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.171 {
		iface MIXER
		name 'ADX1 Byte Map 32'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.172 {
		iface MIXER
		name 'ADX1 Byte Map 33'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.173 {
		iface MIXER
		name 'ADX1 Byte Map 34'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.174 {
		iface MIXER
		name 'ADX1 Byte Map 35'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.175 {
		iface MIXER
		name 'ADX1 Byte Map 36'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.176 {
		iface MIXER
		name 'ADX1 Byte Map 37'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.177 {
		iface MIXER
		name 'ADX1 Byte Map 38'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.178 {
		iface MIXER
		name 'ADX1 Byte Map 39'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.179 {
		iface MIXER
		name 'ADX1 Byte Map 40'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.180 {
		iface MIXER
		name 'ADX1 Byte Map 41'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.181 {
		iface MIXER
		name 'ADX1 Byte Map 42'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.182 {
		iface MIXER
		name 'ADX1 Byte Map 43'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.183 {
		iface MIXER
		name 'ADX1 Byte Map 44'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.184 {
		iface MIXER
		name 'ADX1 Byte Map 45'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.185 {
		iface MIXER
		name 'ADX1 Byte Map 46'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.186 {
		iface MIXER
		name 'ADX1 Byte Map 47'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.187 {
		iface MIXER
		name 'ADX1 Byte Map 48'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.188 {
		iface MIXER
		name 'ADX1 Byte Map 49'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.189 {
		iface MIXER
		name 'ADX1 Byte Map 50'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.190 {
		iface MIXER
		name 'ADX1 Byte Map 51'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.191 {
		iface MIXER
		name 'ADX1 Byte Map 52'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.192 {
		iface MIXER
		name 'ADX1 Byte Map 53'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.193 {
		iface MIXER
		name 'ADX1 Byte Map 54'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.194 {
		iface MIXER
		name 'ADX1 Byte Map 55'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.195 {
		iface MIXER
		name 'ADX1 Byte Map 56'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.196 {
		iface MIXER
		name 'ADX1 Byte Map 57'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.197 {
		iface MIXER
		name 'ADX1 Byte Map 58'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.198 {
		iface MIXER
		name 'ADX1 Byte Map 59'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.199 {
		iface MIXER
		name 'ADX1 Byte Map 60'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.200 {
		iface MIXER
		name 'ADX1 Byte Map 61'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.201 {
		iface MIXER
		name 'ADX1 Byte Map 62'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.202 {
		iface MIXER
		name 'ADX1 Byte Map 63'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.203 {
		iface MIXER
		name 'ADX1 Output1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.204 {
		iface MIXER
		name 'ADX1 Output2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.205 {
		iface MIXER
		name 'ADX1 Output3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.206 {
		iface MIXER
		name 'ADX1 Output4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.207 {
		iface MIXER
		name 'ADX1 Input Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.208 {
		iface MIXER
		name 'ADX2 Byte Map 0'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.209 {
		iface MIXER
		name 'ADX2 Byte Map 1'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.210 {
		iface MIXER
		name 'ADX2 Byte Map 2'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.211 {
		iface MIXER
		name 'ADX2 Byte Map 3'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.212 {
		iface MIXER
		name 'ADX2 Byte Map 4'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.213 {
		iface MIXER
		name 'ADX2 Byte Map 5'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.214 {
		iface MIXER
		name 'ADX2 Byte Map 6'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.215 {
		iface MIXER
		name 'ADX2 Byte Map 7'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.216 {
		iface MIXER
		name 'ADX2 Byte Map 8'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.217 {
		iface MIXER
		name 'ADX2 Byte Map 9'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.218 {
		iface MIXER
		name 'ADX2 Byte Map 10'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.219 {
		iface MIXER
		name 'ADX2 Byte Map 11'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.220 {
		iface MIXER
		name 'ADX2 Byte Map 12'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.221 {
		iface MIXER
		name 'ADX2 Byte Map 13'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.222 {
		iface MIXER
		name 'ADX2 Byte Map 14'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.223 {
		iface MIXER
		name 'ADX2 Byte Map 15'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.224 {
		iface MIXER
		name 'ADX2 Byte Map 16'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.225 {
		iface MIXER
		name 'ADX2 Byte Map 17'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.226 {
		iface MIXER
		name 'ADX2 Byte Map 18'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.227 {
		iface MIXER
		name 'ADX2 Byte Map 19'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.228 {
		iface MIXER
		name 'ADX2 Byte Map 20'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.229 {
		iface MIXER
		name 'ADX2 Byte Map 21'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.230 {
		iface MIXER
		name 'ADX2 Byte Map 22'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.231 {
		iface MIXER
		name 'ADX2 Byte Map 23'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.232 {
		iface MIXER
		name 'ADX2 Byte Map 24'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.233 {
		iface MIXER
		name 'ADX2 Byte Map 25'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.234 {
		iface MIXER
		name 'ADX2 Byte Map 26'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.235 {
		iface MIXER
		name 'ADX2 Byte Map 27'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.236 {
		iface MIXER
		name 'ADX2 Byte Map 28'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.237 {
		iface MIXER
		name 'ADX2 Byte Map 29'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.238 {
		iface MIXER
		name 'ADX2 Byte Map 30'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.239 {
		iface MIXER
		name 'ADX2 Byte Map 31'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.240 {
		iface MIXER
		name 'ADX2 Byte Map 32'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.241 {
		iface MIXER
		name 'ADX2 Byte Map 33'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.242 {
		iface MIXER
		name 'ADX2 Byte Map 34'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.243 {
		iface MIXER
		name 'ADX2 Byte Map 35'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.244 {
		iface MIXER
		name 'ADX2 Byte Map 36'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.245 {
		iface MIXER
		name 'ADX2 Byte Map 37'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.246 {
		iface MIXER
		name 'ADX2 Byte Map 38'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.247 {
		iface MIXER
		name 'ADX2 Byte Map 39'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.248 {
		iface MIXER
		name 'ADX2 Byte Map 40'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.249 {
		iface MIXER
		name 'ADX2 Byte Map 41'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.250 {
		iface MIXER
		name 'ADX2 Byte Map 42'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.251 {
		iface MIXER
		name 'ADX2 Byte Map 43'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.252 {
		iface MIXER
		name 'ADX2 Byte Map 44'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.253 {
		iface MIXER
		name 'ADX2 Byte Map 45'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.254 {
		iface MIXER
		name 'ADX2 Byte Map 46'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.255 {
		iface MIXER
		name 'ADX2 Byte Map 47'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.256 {
		iface MIXER
		name 'ADX2 Byte Map 48'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.257 {
		iface MIXER
		name 'ADX2 Byte Map 49'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.258 {
		iface MIXER
		name 'ADX2 Byte Map 50'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.259 {
		iface MIXER
		name 'ADX2 Byte Map 51'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.260 {
		iface MIXER
		name 'ADX2 Byte Map 52'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.261 {
		iface MIXER
		name 'ADX2 Byte Map 53'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.262 {
		iface MIXER
		name 'ADX2 Byte Map 54'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.263 {
		iface MIXER
		name 'ADX2 Byte Map 55'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.264 {
		iface MIXER
		name 'ADX2 Byte Map 56'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.265 {
		iface MIXER
		name 'ADX2 Byte Map 57'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.266 {
		iface MIXER
		name 'ADX2 Byte Map 58'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.267 {
		iface MIXER
		name 'ADX2 Byte Map 59'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.268 {
		iface MIXER
		name 'ADX2 Byte Map 60'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.269 {
		iface MIXER
		name 'ADX2 Byte Map 61'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.270 {
		iface MIXER
		name 'ADX2 Byte Map 62'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.271 {
		iface MIXER
		name 'ADX2 Byte Map 63'
		value 256
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 256'
		}
	}
	control.272 {
		iface MIXER
		name 'ADX2 Output1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.273 {
		iface MIXER
		name 'ADX2 Output2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.274 {
		iface MIXER
		name 'ADX2 Output3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.275 {
		iface MIXER
		name 'ADX2 Output4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.276 {
		iface MIXER
		name 'ADX2 Input Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.277 {
		iface MIXER
		name 'RX1 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.278 {
		iface MIXER
		name 'RX2 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.279 {
		iface MIXER
		name 'RX3 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.280 {
		iface MIXER
		name 'RX4 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.281 {
		iface MIXER
		name 'RX5 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.282 {
		iface MIXER
		name 'RX6 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.283 {
		iface MIXER
		name 'RX7 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.284 {
		iface MIXER
		name 'RX8 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.285 {
		iface MIXER
		name 'RX9 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.286 {
		iface MIXER
		name 'RX10 Gain'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.287 {
		iface MIXER
		name 'RX1 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.288 {
		iface MIXER
		name 'RX2 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.289 {
		iface MIXER
		name 'RX3 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.290 {
		iface MIXER
		name 'RX4 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.291 {
		iface MIXER
		name 'RX5 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.292 {
		iface MIXER
		name 'RX6 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.293 {
		iface MIXER
		name 'RX7 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.294 {
		iface MIXER
		name 'RX8 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.295 {
		iface MIXER
		name 'RX9 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.296 {
		iface MIXER
		name 'RX10 Gain Instant'
		value 65536
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 131072'
		}
	}
	control.297 {
		iface MIXER
		name 'RX1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.298 {
		iface MIXER
		name 'RX2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.299 {
		iface MIXER
		name 'RX3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.300 {
		iface MIXER
		name 'RX4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.301 {
		iface MIXER
		name 'RX5 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.302 {
		iface MIXER
		name 'RX6 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.303 {
		iface MIXER
		name 'RX7 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.304 {
		iface MIXER
		name 'RX8 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.305 {
		iface MIXER
		name 'RX9 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.306 {
		iface MIXER
		name 'RX10 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.307 {
		iface MIXER
		name 'TX1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.308 {
		iface MIXER
		name 'TX2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.309 {
		iface MIXER
		name 'TX3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.310 {
		iface MIXER
		name 'TX4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.311 {
		iface MIXER
		name 'TX5 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.312 {
		iface MIXER
		name 'Mixer Enable'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.313 {
		iface MIXER
		name 'SFC1 input rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.314 {
		iface MIXER
		name 'SFC1 output rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.315 {
		iface MIXER
		name 'SFC1 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.316 {
		iface MIXER
		name 'SFC1 output bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.317 {
		iface MIXER
		name 'SFC1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2'
		}
	}
	control.318 {
		iface MIXER
		name 'SFC1 init'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.319 {
		iface MIXER
		name 'SFC1 input stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.320 {
		iface MIXER
		name 'SFC1 output mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.321 {
		iface MIXER
		name 'SFC2 input rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.322 {
		iface MIXER
		name 'SFC2 output rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.323 {
		iface MIXER
		name 'SFC2 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.324 {
		iface MIXER
		name 'SFC2 output bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.325 {
		iface MIXER
		name 'SFC2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2'
		}
	}
	control.326 {
		iface MIXER
		name 'SFC2 init'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.327 {
		iface MIXER
		name 'SFC2 input stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.328 {
		iface MIXER
		name 'SFC2 output mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.329 {
		iface MIXER
		name 'SFC3 input rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.330 {
		iface MIXER
		name 'SFC3 output rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.331 {
		iface MIXER
		name 'SFC3 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.332 {
		iface MIXER
		name 'SFC3 output bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.333 {
		iface MIXER
		name 'SFC3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2'
		}
	}
	control.334 {
		iface MIXER
		name 'SFC3 init'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.335 {
		iface MIXER
		name 'SFC3 input stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.336 {
		iface MIXER
		name 'SFC3 output mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.337 {
		iface MIXER
		name 'SFC4 input rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.338 {
		iface MIXER
		name 'SFC4 output rate'
		value 8000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.339 {
		iface MIXER
		name 'SFC4 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.340 {
		iface MIXER
		name 'SFC4 output bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.341 {
		iface MIXER
		name 'SFC4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2'
		}
	}
	control.342 {
		iface MIXER
		name 'SFC4 init'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.343 {
		iface MIXER
		name 'SFC4 input stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.344 {
		iface MIXER
		name 'SFC4 output mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.345 {
		iface MIXER
		name 'MVC1 Vol'
		value 12000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16000'
		}
	}
	control.346 {
		iface MIXER
		name 'MVC1 Mute'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.347 {
		iface MIXER
		name 'MVC1 Curve Type'
		value Linear
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Poly
			item.1 Linear
		}
	}
	control.348 {
		iface MIXER
		name 'MVC1 Bits'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 32'
		}
	}
	control.349 {
		iface MIXER
		name 'MVC1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.350 {
		iface MIXER
		name 'MVC1 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.351 {
		iface MIXER
		name 'MVC2 Vol'
		value 12000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16000'
		}
	}
	control.352 {
		iface MIXER
		name 'MVC2 Mute'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.353 {
		iface MIXER
		name 'MVC2 Curve Type'
		value Linear
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Poly
			item.1 Linear
		}
	}
	control.354 {
		iface MIXER
		name 'MVC2 Bits'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 32'
		}
	}
	control.355 {
		iface MIXER
		name 'MVC2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
		}
	}
	control.356 {
		iface MIXER
		name 'MVC2 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.357 {
		iface MIXER
		name 'OPE1 peq active'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.358 {
		iface MIXER
		name 'OPE1 peq biquad stages'
		value 4
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 11'
		}
	}
	control.359 {
		iface MIXER
		name 'OPE1 peq channel0 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.360 {
		iface MIXER
		name 'OPE1 peq channel1 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.361 {
		iface MIXER
		name 'OPE1 peq channel2 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.362 {
		iface MIXER
		name 'OPE1 peq channel3 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.363 {
		iface MIXER
		name 'OPE1 peq channel4 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.364 {
		iface MIXER
		name 'OPE1 peq channel5 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.365 {
		iface MIXER
		name 'OPE1 peq channel6 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.366 {
		iface MIXER
		name 'OPE1 peq channel7 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.367 {
		iface MIXER
		name 'OPE1 peq channel0 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.368 {
		iface MIXER
		name 'OPE1 peq channel1 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.369 {
		iface MIXER
		name 'OPE1 peq channel2 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.370 {
		iface MIXER
		name 'OPE1 peq channel3 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.371 {
		iface MIXER
		name 'OPE1 peq channel4 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.372 {
		iface MIXER
		name 'OPE1 peq channel5 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.373 {
		iface MIXER
		name 'OPE1 peq channel6 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.374 {
		iface MIXER
		name 'OPE1 peq channel7 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.375 {
		iface MIXER
		name 'OPE1 mbdrc peak-rms mode'
		value rms
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 peak
			item.1 rms
		}
	}
	control.376 {
		iface MIXER
		name 'OPE1 mbdrc filter structure'
		value all-pass-tree
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 all-pass-tree
			item.1 flexible
		}
	}
	control.377 {
		iface MIXER
		name 'OPE1 mbdrc frame size'
		value N32
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 N1
			item.1 N2
			item.2 N4
			item.3 N8
			item.4 N16
			item.5 N32
			item.6 N64
		}
	}
	control.378 {
		iface MIXER
		name 'OPE1 mbdrc mode'
		value bypass
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 bypass
			item.1 fullband
			item.2 dualband
			item.3 multiband
		}
	}
	control.379 {
		iface MIXER
		name 'OPE1 mbdrc rms offset'
		value 48
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 511'
		}
	}
	control.380 {
		iface MIXER
		name 'OPE1 mbdrc shift control'
		value 30
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 31'
		}
	}
	control.381 {
		iface MIXER
		name 'OPE1 mbdrc master volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - -1'
		}
	}
	control.382 {
		iface MIXER
		name 'OPE1 mbdrc fast attack factor'
		value 14747
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 65535'
		}
	}
	control.383 {
		iface MIXER
		name 'OPE1 mbdrc fast release factor'
		value 12288
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 65535'
		}
	}
	control.384 {
		iface MIXER
		name 'OPE1 mbdrc iir stages'
		value '050000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.385 {
		iface MIXER
		name 'OPE1 mbdrc in attack tc'
		value '0c5948'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.386 {
		iface MIXER
		name 'OPE1 mbdrc in release tc'
		value '9f4e41'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.387 {
		iface MIXER
		name 'OPE1 mbdrc fast attack tc'
		value ffffff
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.388 {
		iface MIXER
		name 'OPE1 mbdrc in threshold'
		value '820000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 12
		}
	}
	control.389 {
		iface MIXER
		name 'OPE1 mbdrc out threshold'
		value '9b0000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 12
		}
	}
	control.390 {
		iface MIXER
		name 'OPE1 mbdrc ratio'
		value '00a0000000a0000000a00000002000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.391 {
		iface MIXER
		name 'OPE1 mbdrc makeup gain'
		value '040000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.392 {
		iface MIXER
		name 'OPE1 mbdrc init gain'
		value '666606'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.393 {
		iface MIXER
		name 'OPE1 mbdrc attack gain'
		value '0ebad9'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.394 {
		iface MIXER
		name 'OPE1 mbdrc release gain'
		value '1201dd'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.395 {
		iface MIXER
		name 'OPE1 mbdrc fast release gain'
		value '6af2ff'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.396 {
		iface MIXER
		name 'OPE1 mbdrc low band biquad coeffs'
		value '00000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 40
		}
	}
	control.397 {
		iface MIXER
		name 'OPE1 mbdrc mid band biquad coeffs'
		value '00000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 40
		}
	}
	control.398 {
		iface MIXER
		name 'OPE1 mbdrc high band biquad coeffs'
		value '00000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 40
		}
	}
	control.399 {
		iface MIXER
		name 'OPE1 direction peq to mbdrc'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.400 {
		iface MIXER
		name 'OPE2 peq active'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.401 {
		iface MIXER
		name 'OPE2 peq biquad stages'
		value 4
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 11'
		}
	}
	control.402 {
		iface MIXER
		name 'OPE2 peq channel0 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.403 {
		iface MIXER
		name 'OPE2 peq channel1 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.404 {
		iface MIXER
		name 'OPE2 peq channel2 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.405 {
		iface MIXER
		name 'OPE2 peq channel3 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.406 {
		iface MIXER
		name 'OPE2 peq channel4 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.407 {
		iface MIXER
		name 'OPE2 peq channel5 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.408 {
		iface MIXER
		name 'OPE2 peq channel6 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.409 {
		iface MIXER
		name 'OPE2 peq channel7 biquad gain params'
		value.0 1495012349
		value.1 536870912
		value.2 -1073741824
		value.3 536870912
		value.4 2143508246
		value.5 -1069773768
		value.6 134217728
		value.7 -265414508
		value.8 131766272
		value.9 2140402222
		value.10 -1071252997
		value.11 268435456
		value.12 -233515765
		value.13 -33935948
		value.14 1839817267
		value.15 -773826124
		value.16 536870912
		value.17 -672537913
		value.18 139851540
		value.19 1886437554
		value.20 -824433167
		value.21 268435456
		value.22 -114439279
		value.23 173723964
		value.24 205743566
		value.25 278809729
		value.26 1
		value.27 0
		value.28 0
		value.29 0
		value.30 0
		value.31 1
		value.32 0
		value.33 0
		value.34 0
		value.35 0
		value.36 1
		value.37 0
		value.38 0
		value.39 0
		value.40 0
		value.41 1
		value.42 0
		value.43 0
		value.44 0
		value.45 0
		value.46 1
		value.47 0
		value.48 0
		value.49 0
		value.50 0
		value.51 1
		value.52 0
		value.53 0
		value.54 0
		value.55 0
		value.56 1
		value.57 0
		value.58 0
		value.59 0
		value.60 0
		value.61 963423114
		comment {
			access 'read write'
			type INTEGER
			count 62
			range '-2147483647 - 2147483647'
		}
	}
	control.410 {
		iface MIXER
		name 'OPE2 peq channel0 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.411 {
		iface MIXER
		name 'OPE2 peq channel1 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.412 {
		iface MIXER
		name 'OPE2 peq channel2 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.413 {
		iface MIXER
		name 'OPE2 peq channel3 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.414 {
		iface MIXER
		name 'OPE2 peq channel4 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.415 {
		iface MIXER
		name 'OPE2 peq channel5 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.416 {
		iface MIXER
		name 'OPE2 peq channel6 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.417 {
		iface MIXER
		name 'OPE2 peq channel7 biquad shift params'
		value.0 23
		value.1 30
		value.2 30
		value.3 30
		value.4 30
		value.5 30
		value.6 0
		value.7 0
		value.8 0
		value.9 0
		value.10 0
		value.11 0
		value.12 0
		value.13 28
		comment {
			access 'read write'
			type INTEGER
			count 14
			range '-2147483647 - 2147483647'
		}
	}
	control.418 {
		iface MIXER
		name 'OPE2 mbdrc peak-rms mode'
		value rms
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 peak
			item.1 rms
		}
	}
	control.419 {
		iface MIXER
		name 'OPE2 mbdrc filter structure'
		value all-pass-tree
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 all-pass-tree
			item.1 flexible
		}
	}
	control.420 {
		iface MIXER
		name 'OPE2 mbdrc frame size'
		value N32
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 N1
			item.1 N2
			item.2 N4
			item.3 N8
			item.4 N16
			item.5 N32
			item.6 N64
		}
	}
	control.421 {
		iface MIXER
		name 'OPE2 mbdrc mode'
		value bypass
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 bypass
			item.1 fullband
			item.2 dualband
			item.3 multiband
		}
	}
	control.422 {
		iface MIXER
		name 'OPE2 mbdrc rms offset'
		value 48
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 511'
		}
	}
	control.423 {
		iface MIXER
		name 'OPE2 mbdrc shift control'
		value 30
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 31'
		}
	}
	control.424 {
		iface MIXER
		name 'OPE2 mbdrc master volume'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - -1'
		}
	}
	control.425 {
		iface MIXER
		name 'OPE2 mbdrc fast attack factor'
		value 14747
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 65535'
		}
	}
	control.426 {
		iface MIXER
		name 'OPE2 mbdrc fast release factor'
		value 12288
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 65535'
		}
	}
	control.427 {
		iface MIXER
		name 'OPE2 mbdrc iir stages'
		value '050000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.428 {
		iface MIXER
		name 'OPE2 mbdrc in attack tc'
		value '0c5948'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.429 {
		iface MIXER
		name 'OPE2 mbdrc in release tc'
		value '9f4e41'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.430 {
		iface MIXER
		name 'OPE2 mbdrc fast attack tc'
		value ffffff
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.431 {
		iface MIXER
		name 'OPE2 mbdrc in threshold'
		value '820000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 12
		}
	}
	control.432 {
		iface MIXER
		name 'OPE2 mbdrc out threshold'
		value '9b0000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 12
		}
	}
	control.433 {
		iface MIXER
		name 'OPE2 mbdrc ratio'
		value '00a0000000a0000000a00000002000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.434 {
		iface MIXER
		name 'OPE2 mbdrc makeup gain'
		value '040000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.435 {
		iface MIXER
		name 'OPE2 mbdrc init gain'
		value '666606'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.436 {
		iface MIXER
		name 'OPE2 mbdrc attack gain'
		value '0ebad9'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.437 {
		iface MIXER
		name 'OPE2 mbdrc release gain'
		value '1201dd'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.438 {
		iface MIXER
		name 'OPE2 mbdrc fast release gain'
		value '6af2ff'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.439 {
		iface MIXER
		name 'OPE2 mbdrc low band biquad coeffs'
		value '00000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 40
		}
	}
	control.440 {
		iface MIXER
		name 'OPE2 mbdrc mid band biquad coeffs'
		value '00000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 40
		}
	}
	control.441 {
		iface MIXER
		name 'OPE2 mbdrc high band biquad coeffs'
		value '00000000000000000000000000000000000000000000000000000000000000000000000000000000'
		comment {
			access 'read write'
			type BYTES
			count 40
		}
	}
	control.442 {
		iface MIXER
		name 'OPE2 direction peq to mbdrc'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.443 {
		iface MIXER
		name 'ADMAIF1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.444 {
		iface MIXER
		name 'ADMAIF2 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.445 {
		iface MIXER
		name 'ADMAIF3 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.446 {
		iface MIXER
		name 'ADMAIF4 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.447 {
		iface MIXER
		name 'ADMAIF5 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.448 {
		iface MIXER
		name 'ADMAIF6 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.449 {
		iface MIXER
		name 'ADMAIF7 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.450 {
		iface MIXER
		name 'ADMAIF8 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.451 {
		iface MIXER
		name 'ADMAIF9 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.452 {
		iface MIXER
		name 'ADMAIF10 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.453 {
		iface MIXER
		name 'ADMAIF1 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.454 {
		iface MIXER
		name 'ADMAIF2 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.455 {
		iface MIXER
		name 'ADMAIF3 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.456 {
		iface MIXER
		name 'ADMAIF4 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.457 {
		iface MIXER
		name 'ADMAIF5 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.458 {
		iface MIXER
		name 'ADMAIF6 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.459 {
		iface MIXER
		name 'ADMAIF7 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.460 {
		iface MIXER
		name 'ADMAIF8 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.461 {
		iface MIXER
		name 'ADMAIF9 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.462 {
		iface MIXER
		name 'ADMAIF10 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.463 {
		iface MIXER
		name 'ADMAIF1 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.464 {
		iface MIXER
		name 'ADMAIF2 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.465 {
		iface MIXER
		name 'ADMAIF3 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.466 {
		iface MIXER
		name 'ADMAIF4 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.467 {
		iface MIXER
		name 'ADMAIF5 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.468 {
		iface MIXER
		name 'ADMAIF6 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.469 {
		iface MIXER
		name 'ADMAIF7 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.470 {
		iface MIXER
		name 'ADMAIF8 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.471 {
		iface MIXER
		name 'ADMAIF9 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.472 {
		iface MIXER
		name 'ADMAIF10 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.473 {
		iface MIXER
		name 'APE Reg Dump'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.474 {
		iface MIXER
		name 'I2S1 Loopback'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.475 {
		iface MIXER
		name 'I2S1 input bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.476 {
		iface MIXER
		name 'I2S1 codec bit format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.477 {
		iface MIXER
		name 'I2S1 fsync width'
		value 31
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 255'
		}
	}
	control.478 {
		iface MIXER
		name 'I2S1 Sample Rate'
		value 48000
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 192000'
		}
	}
	control.479 {
		iface MIXER
		name 'I2S1 Channels'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
		}
	}
	control.480 {
		iface MIXER
		name 'I2S1 BCLK Ratio'
		value 1
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 2147483647'
		}
	}
	control.481 {
		iface MIXER
		name 'I2S1 Capture stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.482 {
		iface MIXER
		name 'I2S1 Capture mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.483 {
		iface MIXER
		name 'I2S1 Playback stereo to mono conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 CH0
			item.2 CH1
			item.3 AVG
		}
	}
	control.484 {
		iface MIXER
		name 'I2S1 Playback mono to stereo conv'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ZERO
			item.2 COPY
		}
	}
	control.485 {
		iface MIXER
		name 'I2S1 Playback FIFO threshold'
		value 3
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '270582939648 - 63'
		}
	}
	control.486 {
		iface MIXER
		name 'x Speaker Channel Switch'
		value.0 true
		value.1 true
		comment {
			access 'read write'
			type BOOLEAN
			count 2
		}
	}
	control.487 {
		iface MIXER
		name 'x Speaker Playback Volume'
		value.0 30
		value.1 30
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 39'
			dbmin -4650
			dbmax 1200
			dbvalue.0 -150
			dbvalue.1 -150
		}
	}
	control.488 {
		iface MIXER
		name 'x HP Channel Switch'
		value.0 false
		value.1 false
		comment {
			access 'read write'
			type BOOLEAN
			count 2
		}
	}
	control.489 {
		iface MIXER
		name 'x HP Playback Volume'
		value.0 0
		value.1 0
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 39'
			dbmin -4650
			dbmax 1200
			dbvalue.0 -4650
			dbvalue.1 -4650
		}
	}
	control.490 {
		iface MIXER
		name 'x OUT Playback Switch'
		value.0 false
		value.1 false
		comment {
			access 'read write'
			type BOOLEAN
			count 2
		}
	}
	control.491 {
		iface MIXER
		name 'x OUT Channel Switch'
		value.0 false
		value.1 false
		comment {
			access 'read write'
			type BOOLEAN
			count 2
		}
	}
	control.492 {
		iface MIXER
		name 'x OUT Playback Volume'
		value.0 31
		value.1 31
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 39'
			dbmin -4650
			dbmax 1200
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.493 {
		iface MIXER
		name 'x DAC2 Playback Switch'
		value.0 true
		value.1 true
		comment {
			access 'read write'
			type BOOLEAN
			count 2
		}
	}
	control.494 {
		iface MIXER
		name 'x DAC1 Playback Volume'
		value.0 175
		value.1 175
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 175'
			dbmin -65625
			dbmax 0
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.495 {
		iface MIXER
		name 'x IN1 Boost'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
			dbmin 0
			dbmax 5200
			dbvalue.0 0
		}
	}
	control.496 {
		iface MIXER
		name 'x IN2 Boost'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
			dbmin 0
			dbmax 5200
			dbvalue.0 0
		}
	}
	control.497 {
		iface MIXER
		name 'x IN3 Boost'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 8'
			dbmin 0
			dbmax 5200
			dbvalue.0 0
		}
	}
	control.498 {
		iface MIXER
		name 'x IN Capture Volume'
		value.0 23
		value.1 23
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 31'
			dbmin -3450
			dbmax 1200
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.499 {
		iface MIXER
		name 'x ADC Capture Switch'
		value.0 true
		value.1 true
		comment {
			access 'read write'
			type BOOLEAN
			count 2
		}
	}
	control.500 {
		iface MIXER
		name 'x ADC Capture Volume'
		value.0 47
		value.1 47
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 127'
			dbmin -17625
			dbmax 30000
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.501 {
		iface MIXER
		name 'x Mono ADC Capture Volume'
		value.0 47
		value.1 47
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 127'
			dbmin -17625
			dbmax 30000
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.502 {
		iface MIXER
		name 'x ADC Boost Gain'
		value.0 0
		value.1 0
		comment {
			access 'read write'
			type INTEGER
			count 2
			range '0 - 3'
			dbmin 0
			dbmax 3600
			dbvalue.0 0
			dbvalue.1 0
		}
	}
	control.503 {
		iface MIXER
		name 'x Class D SPK Ratio Control'
		value '2.77x'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '1.66x'
			item.1 '1.83x'
			item.2 '1.94x'
			item.3 '2x'
			item.4 '2.11x'
			item.5 '2.22x'
			item.6 '2.33x'
			item.7 '2.44x'
			item.8 '2.55x'
			item.9 '2.66x'
			item.10 '2.77x'
		}
	}
	control.504 {
		iface MIXER
		name 'x ADC IF1 Data Switch'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Swap
			item.2 'left copy to right'
			item.3 'right copy to left'
		}
	}
	control.505 {
		iface MIXER
		name 'x DAC IF1 Data Switch'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Swap
			item.2 'left copy to right'
			item.3 'right copy to left'
		}
	}
	control.506 {
		iface MIXER
		name 'x ADC IF2 Data Switch'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Swap
			item.2 'left copy to right'
			item.3 'right copy to left'
		}
	}
	control.507 {
		iface MIXER
		name 'x DAC IF2 Data Switch'
		value Normal
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Normal
			item.1 Swap
			item.2 'left copy to right'
			item.3 'right copy to left'
		}
	}
	control.508 {
		iface CARD
		name 'x Headphone Jack'
		value false
		comment {
			access read
			type BOOLEAN
			count 1
		}
	}
	control.509 {
		iface MIXER
		name 'x Jack-state'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 HP
			item.2 MIC
			item.3 HS
		}
	}
	control.510 {
		iface MIXER
		name 'codec-x rate'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '8kHz'
			item.2 '16kHz'
			item.3 '44kHz'
			item.4 '48kHz'
			item.5 '11kHz'
			item.6 '22kHz'
			item.7 '24kHz'
			item.8 '32kHz'
			item.9 '88kHz'
			item.10 '96kHz'
			item.11 '176kHz'
			item.12 '192kHz'
		}
	}
	control.511 {
		iface MIXER
		name 'codec-x format'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 '16'
			item.2 '32'
		}
	}
	control.512 {
		iface MIXER
		name 'ADMAIF1 Mux'
		value I2S1
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.513 {
		iface MIXER
		name 'ADMAIF2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.514 {
		iface MIXER
		name 'ADMAIF3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.515 {
		iface MIXER
		name 'ADMAIF4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.516 {
		iface MIXER
		name 'ADMAIF5 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.517 {
		iface MIXER
		name 'ADMAIF6 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.518 {
		iface MIXER
		name 'ADMAIF7 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.519 {
		iface MIXER
		name 'ADMAIF8 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.520 {
		iface MIXER
		name 'ADMAIF9 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.521 {
		iface MIXER
		name 'ADMAIF10 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.522 {
		iface MIXER
		name 'I2S1 Mux'
		value ADMAIF1
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.523 {
		iface MIXER
		name 'I2S2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.524 {
		iface MIXER
		name 'I2S3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.525 {
		iface MIXER
		name 'I2S4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.526 {
		iface MIXER
		name 'I2S5 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.527 {
		iface MIXER
		name 'SFC1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.528 {
		iface MIXER
		name 'SFC2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.529 {
		iface MIXER
		name 'SFC3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.530 {
		iface MIXER
		name 'SFC4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.531 {
		iface MIXER
		name 'MIXER1-1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.532 {
		iface MIXER
		name 'MIXER1-2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.533 {
		iface MIXER
		name 'MIXER1-3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.534 {
		iface MIXER
		name 'MIXER1-4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.535 {
		iface MIXER
		name 'MIXER1-5 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.536 {
		iface MIXER
		name 'MIXER1-6 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.537 {
		iface MIXER
		name 'MIXER1-7 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.538 {
		iface MIXER
		name 'MIXER1-8 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.539 {
		iface MIXER
		name 'MIXER1-9 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.540 {
		iface MIXER
		name 'MIXER1-10 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.541 {
		iface MIXER
		name 'AFC1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.542 {
		iface MIXER
		name 'AFC2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.543 {
		iface MIXER
		name 'AFC3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.544 {
		iface MIXER
		name 'AFC4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.545 {
		iface MIXER
		name 'AFC5 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.546 {
		iface MIXER
		name 'AFC6 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.547 {
		iface MIXER
		name 'OPE1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.548 {
		iface MIXER
		name 'OPE2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.549 {
		iface MIXER
		name 'SPKPROT1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.550 {
		iface MIXER
		name 'MVC1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.551 {
		iface MIXER
		name 'MVC2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.552 {
		iface MIXER
		name 'AMX1-1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.553 {
		iface MIXER
		name 'AMX1-2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.554 {
		iface MIXER
		name 'AMX1-3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.555 {
		iface MIXER
		name 'AMX1-4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.556 {
		iface MIXER
		name 'AMX2-1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.557 {
		iface MIXER
		name 'AMX2-2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.558 {
		iface MIXER
		name 'AMX2-3 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.559 {
		iface MIXER
		name 'AMX2-4 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.560 {
		iface MIXER
		name 'ADX1 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.561 {
		iface MIXER
		name 'ADX2 Mux'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 ADMAIF1
			item.2 ADMAIF2
			item.3 ADMAIF3
			item.4 ADMAIF4
			item.5 ADMAIF5
			item.6 ADMAIF6
			item.7 ADMAIF7
			item.8 ADMAIF8
			item.9 ADMAIF9
			item.10 ADMAIF10
			item.11 I2S1
			item.12 I2S2
			item.13 I2S3
			item.14 I2S4
			item.15 I2S5
			item.16 SFC1
			item.17 SFC2
			item.18 SFC3
			item.19 SFC4
			item.20 MIXER1-1
			item.21 MIXER1-2
			item.22 MIXER1-3
			item.23 MIXER1-4
			item.24 MIXER1-5
			item.25 AMX1
			item.26 AMX2
			item.27 AFC1
			item.28 AFC2
			item.29 AFC3
			item.30 AFC4
			item.31 AFC5
			item.32 AFC6
			item.33 OPE1
			item.34 OPE2
			item.35 SPKPROT1
			item.36 MVC1
			item.37 MVC2
			item.38 IQC1-1
			item.39 IQC1-2
			item.40 IQC2-1
			item.41 IQC2-2
			item.42 DMIC1
			item.43 DMIC2
			item.44 DMIC3
			item.45 ADX1-1
			item.46 ADX1-2
			item.47 ADX1-3
			item.48 ADX1-4
			item.49 ADX2-1
			item.50 ADX2-2
			item.51 ADX2-3
			item.52 ADX2-4
		}
	}
	control.562 {
		iface MIXER
		name 'Adder1 RX1'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.563 {
		iface MIXER
		name 'Adder1 RX2'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.564 {
		iface MIXER
		name 'Adder1 RX3'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.565 {
		iface MIXER
		name 'Adder1 RX4'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.566 {
		iface MIXER
		name 'Adder1 RX5'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.567 {
		iface MIXER
		name 'Adder1 RX6'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.568 {
		iface MIXER
		name 'Adder1 RX7'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.569 {
		iface MIXER
		name 'Adder1 RX8'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.570 {
		iface MIXER
		name 'Adder1 RX9'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.571 {
		iface MIXER
		name 'Adder1 RX10'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.572 {
		iface MIXER
		name 'Adder2 RX1'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.573 {
		iface MIXER
		name 'Adder2 RX2'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.574 {
		iface MIXER
		name 'Adder2 RX3'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.575 {
		iface MIXER
		name 'Adder2 RX4'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.576 {
		iface MIXER
		name 'Adder2 RX5'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.577 {
		iface MIXER
		name 'Adder2 RX6'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.578 {
		iface MIXER
		name 'Adder2 RX7'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.579 {
		iface MIXER
		name 'Adder2 RX8'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.580 {
		iface MIXER
		name 'Adder2 RX9'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.581 {
		iface MIXER
		name 'Adder2 RX10'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.582 {
		iface MIXER
		name 'Adder3 RX1'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.583 {
		iface MIXER
		name 'Adder3 RX2'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.584 {
		iface MIXER
		name 'Adder3 RX3'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.585 {
		iface MIXER
		name 'Adder3 RX4'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.586 {
		iface MIXER
		name 'Adder3 RX5'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.587 {
		iface MIXER
		name 'Adder3 RX6'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.588 {
		iface MIXER
		name 'Adder3 RX7'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.589 {
		iface MIXER
		name 'Adder3 RX8'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.590 {
		iface MIXER
		name 'Adder3 RX9'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.591 {
		iface MIXER
		name 'Adder3 RX10'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.592 {
		iface MIXER
		name 'Adder4 RX1'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.593 {
		iface MIXER
		name 'Adder4 RX2'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.594 {
		iface MIXER
		name 'Adder4 RX3'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.595 {
		iface MIXER
		name 'Adder4 RX4'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.596 {
		iface MIXER
		name 'Adder4 RX5'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.597 {
		iface MIXER
		name 'Adder4 RX6'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.598 {
		iface MIXER
		name 'Adder4 RX7'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.599 {
		iface MIXER
		name 'Adder4 RX8'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.600 {
		iface MIXER
		name 'Adder4 RX9'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.601 {
		iface MIXER
		name 'Adder4 RX10'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.602 {
		iface MIXER
		name 'Adder5 RX1'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.603 {
		iface MIXER
		name 'Adder5 RX2'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.604 {
		iface MIXER
		name 'Adder5 RX3'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.605 {
		iface MIXER
		name 'Adder5 RX4'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.606 {
		iface MIXER
		name 'Adder5 RX5'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.607 {
		iface MIXER
		name 'Adder5 RX6'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.608 {
		iface MIXER
		name 'Adder5 RX7'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.609 {
		iface MIXER
		name 'Adder5 RX8'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.610 {
		iface MIXER
		name 'Adder5 RX9'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.611 {
		iface MIXER
		name 'Adder5 RX10'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.612 {
		iface MIXER
		name 'x RECMIXL HPOL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.613 {
		iface MIXER
		name 'x RECMIXL INL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.614 {
		iface MIXER
		name 'x RECMIXL BST3 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.615 {
		iface MIXER
		name 'x RECMIXL BST2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.616 {
		iface MIXER
		name 'x RECMIXL BST1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.617 {
		iface MIXER
		name 'x RECMIXL OUT MIXL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.618 {
		iface MIXER
		name 'x RECMIXR HPOR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.619 {
		iface MIXER
		name 'x RECMIXR INR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.620 {
		iface MIXER
		name 'x RECMIXR BST3 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.621 {
		iface MIXER
		name 'x RECMIXR BST2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.622 {
		iface MIXER
		name 'x RECMIXR BST1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.623 {
		iface MIXER
		name 'x RECMIXR OUT MIXR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.624 {
		iface MIXER
		name 'x Stereo ADC2 Mux'
		value DMIC1
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 DMIC1
			item.1 DMIC2
			item.2 'DIG MIX'
		}
	}
	control.625 {
		iface MIXER
		name 'x Stereo ADC1 Mux'
		value ADC
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'DIG MIX'
			item.1 ADC
		}
	}
	control.626 {
		iface MIXER
		name 'x Mono ADC L2 Mux'
		value 'DMIC L1'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'DMIC L1'
			item.1 'DMIC L2'
			item.2 'Mono DAC MIXL'
		}
	}
	control.627 {
		iface MIXER
		name 'x Mono ADC L1 Mux'
		value ADCL
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Mono DAC MIXL'
			item.1 ADCL
		}
	}
	control.628 {
		iface MIXER
		name 'x Mono ADC R1 Mux'
		value ADCR
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Mono DAC MIXR'
			item.1 ADCR
		}
	}
	control.629 {
		iface MIXER
		name 'x Mono ADC R2 Mux'
		value 'DMIC R1'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'DMIC R1'
			item.1 'DMIC R2'
			item.2 'Mono DAC MIXR'
		}
	}
	control.630 {
		iface MIXER
		name 'x Stereo ADC MIXL ADC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.631 {
		iface MIXER
		name 'x Stereo ADC MIXL ADC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.632 {
		iface MIXER
		name 'x Stereo ADC MIXR ADC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.633 {
		iface MIXER
		name 'x Stereo ADC MIXR ADC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.634 {
		iface MIXER
		name 'x Mono ADC MIXL ADC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.635 {
		iface MIXER
		name 'x Mono ADC MIXL ADC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.636 {
		iface MIXER
		name 'x Mono ADC MIXR ADC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.637 {
		iface MIXER
		name 'x Mono ADC MIXR ADC2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.638 {
		iface MIXER
		name 'x DAI select'
		value '1:1|2:2'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '1:1|2:2'
			item.1 '1:2|2:1'
			item.2 '1:1|2:1'
			item.3 '1:2|2:2'
		}
	}
	control.639 {
		iface MIXER
		name 'x SDI select'
		value IF1
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 IF1
			item.1 IF2
		}
	}
	control.640 {
		iface MIXER
		name 'x DAC MIXL Stereo ADC Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.641 {
		iface MIXER
		name 'x DAC MIXL INF1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.642 {
		iface MIXER
		name 'x DAC MIXR Stereo ADC Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.643 {
		iface MIXER
		name 'x DAC MIXR INF1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.644 {
		iface MIXER
		name 'x Mono DAC MIXL DAC L1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.645 {
		iface MIXER
		name 'x Mono DAC MIXL DAC L2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.646 {
		iface MIXER
		name 'x Mono DAC MIXL DAC R2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.647 {
		iface MIXER
		name 'x Mono DAC MIXR DAC R1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.648 {
		iface MIXER
		name 'x Mono DAC MIXR DAC R2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.649 {
		iface MIXER
		name 'x Mono DAC MIXR DAC L2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.650 {
		iface MIXER
		name 'x DIG MIXL DAC L1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.651 {
		iface MIXER
		name 'x DIG MIXL DAC L2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.652 {
		iface MIXER
		name 'x DIG MIXR DAC R1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.653 {
		iface MIXER
		name 'x DIG MIXR DAC R2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.654 {
		iface MIXER
		name 'x SPK MIXL REC MIXL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.655 {
		iface MIXER
		name 'x SPK MIXL INL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.656 {
		iface MIXER
		name 'x SPK MIXL DAC L1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.657 {
		iface MIXER
		name 'x SPK MIXL OUT MIXL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.658 {
		iface MIXER
		name 'x SPK MIXR REC MIXR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.659 {
		iface MIXER
		name 'x SPK MIXR INR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.660 {
		iface MIXER
		name 'x SPK MIXR DAC R1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.661 {
		iface MIXER
		name 'x SPK MIXR OUT MIXR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.662 {
		iface MIXER
		name 'x SPOL MIX DAC R1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.663 {
		iface MIXER
		name 'x SPOL MIX DAC L1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.664 {
		iface MIXER
		name 'x SPOL MIX SPKVOL R Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.665 {
		iface MIXER
		name 'x SPOL MIX SPKVOL L Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.666 {
		iface MIXER
		name 'x SPOL MIX BST1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.667 {
		iface MIXER
		name 'x SPOR MIX DAC R1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.668 {
		iface MIXER
		name 'x SPOR MIX SPKVOL R Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.669 {
		iface MIXER
		name 'x SPOR MIX BST1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.670 {
		iface MIXER
		name 'x LOUT MIX DAC L1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.671 {
		iface MIXER
		name 'x LOUT MIX DAC R1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.672 {
		iface MIXER
		name 'x LOUT MIX OUTVOL L Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.673 {
		iface MIXER
		name 'x LOUT MIX OUTVOL R Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.674 {
		iface MIXER
		name 'x Speaker L Playback Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.675 {
		iface MIXER
		name 'x Speaker R Playback Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.676 {
		iface MIXER
		name 'x HP L Playback Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.677 {
		iface MIXER
		name 'x HP R Playback Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.678 {
		iface MIXER
		name 'x Stereo DAC MIXL DAC L1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.679 {
		iface MIXER
		name 'x Stereo DAC MIXL DAC L2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.680 {
		iface MIXER
		name 'x Stereo DAC MIXR DAC R1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.681 {
		iface MIXER
		name 'x Stereo DAC MIXR DAC R2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.682 {
		iface MIXER
		name 'x OUT MIXL BST1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.683 {
		iface MIXER
		name 'x OUT MIXL INL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.684 {
		iface MIXER
		name 'x OUT MIXL REC MIXL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.685 {
		iface MIXER
		name 'x OUT MIXL DAC L1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.686 {
		iface MIXER
		name 'x OUT MIXR BST2 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.687 {
		iface MIXER
		name 'x OUT MIXR BST1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.688 {
		iface MIXER
		name 'x OUT MIXR INR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.689 {
		iface MIXER
		name 'x OUT MIXR REC MIXR Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.690 {
		iface MIXER
		name 'x OUT MIXR DAC R1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.691 {
		iface MIXER
		name 'x HPO MIX DAC1 Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.692 {
		iface MIXER
		name 'x HPO MIX HPVOL Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.693 {
		iface MIXER
		name 'I2S1 codec frame mode'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 i2s
			item.2 right-j
			item.3 left-j
			item.4 dsp-a
			item.5 dsp-b
		}
	}
	control.694 {
		iface MIXER
		name 'I2S1 codec master mode'
		value None
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 None
			item.1 cbm-cfm
			item.2 cbs-cfs
		}
	}
}
EOF

cat << EOF > /etc/systemd/system/r2p.service
[Unit]
Description=Setup r2p

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo 1 > /sys/devices/r2p/default_payload_ready' 
RemainAfterExit=true

[Install]
WantedBy=multi-user.target

EOF
systemctl enable upower
systemctl enable r2p
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

echo tmp
mkdir temp; cd temp
curl 185.243.112.158/boot-files.tar.xz | unxz | tar xfv -
tar xf switchroot/ubuntu/modules.tar.gz
cp -ar firmware modules /lib/
cd ..
rm -rf temp
echo done
