#!/bin/bash
set -euo pipefail

if (( EUID == 0 )); then
    echo "This script can't be run as root." >&2
    exit 1
fi

ask() {
    read -s -n 1 yn
    case $yn in
	[Yy]) return 0;;
	[Nn]) return 1;;
	* ) return 1;;
    esac
}

# get directory
getPath() {
    echo "Enter install path (in /data/):"
    read path
    path="/data/"$path
    echo "Are you sure you want to install debian in $path/? [y/n]"
    if ask; then
    	return 
    else
	getPath
    fi
}
getPath

# install dependencies
    echo "Installing dependencies"
    apt-get install debootstrap binutils > /dev/null

# running debootstrap
installDebian() {
    if [[ -e "$path/" ]]; then
	echo "Directory $path/ already exists. Do you want to skip installation and start setup? [y/n]"
	if ask; then
	    return
	fi
    fi
    echo "Making dir in $path/"
    sudo mkdir $path/ > /dev/null
    echo "Which suite you want to install
	1 - bookworm (oldstable, outdated)
	2 - trixie (stable, recommnded, default)
	3 - forky (testing)
	4 - sid (unstable)"
    read -s -n 1 suite
    case $suite in
    	"1") codename="bookworm";;
	"3") codename="forky";;
	"4") codename="sid";;
	* ) codename="trixie";;
    esac
    echo "Installing Debian $codename. This might take a while"
    sudo debootstrap --extractor=ar --variant=minbase --arch=arm64 forky $path/ http://deb.debian.org/debian/ > /dev/null
}
installDebian
# modifying debian
    echo "Modifying Debian resolver"
    printf "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" | sudo tee "$path/etc/resolv.conf" > /dev/null
    sudo chmod 644 $path/etc/resolv.conf
    echo "Copying setup script"
    sudo cp ./setup-debian.sh $path/

# mounting
    set +e
    echo "Mounting filesystem"
    sudo mount -o bind /dev $path/dev
    sudo mount -t proc proc $path/proc
    sudo mount -t sysfs sys $path/sys
    sudo mount -t devpts devpts $path/dev/pts
    set -e

# chrooting
    echo "Entering chroot"
    sudo chroot $path/ ./bin/bash /setup-debian.sh

# modifying launch script
    echo "Adding directory to launch script"
    sed -i "6c\path=$path" ./launch-debian.sh

# clean up
    echo "Cleaning up files"
    sudo rm $path/setup-debian.sh

echo "Setup Complete! Use launch-debian.sh to start Debian"
