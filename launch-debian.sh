#!/bin/bash
if (( EUID != 0 )); then
    echo "This script must be run as root." >&2
    exit 1
fi
path=/data/debian

mount -o bind /dev $path/dev
mount -t proc proc $path/proc
mount -t sysfs sys $path/sys
mount -t devpts devpts $path/dev/pts
unset LD_PRELOAD
unset TMPDIR
unset TMP
unset TEMP
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TMPDIR=/tmp
chroot $path/ ./bin/bash -c '/autorun.sh && ./bin/bash'
