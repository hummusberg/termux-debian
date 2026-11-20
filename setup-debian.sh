#!/bin/bash
set -euo pipefail

# setting up env variables
    echo "Setting up env variables"
    unset LD_PRELOAD
    unset TMPDIR
    unset TMP
    unset TEMP
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export TMPDIR=/tmp

# install perl
    echo "Installing required packages this might take a while"
    apt-get update > /dev/null
    apt-get download -y perl-base > /dev/null
    apt-get install -y ./perl-*> /dev/null
    rm ./perl-* > /dev/null

# user creation
    echo "Starting user setup"
    id=$(awk -F: '{if($3>max) max=$3} END{print max+1}' /etc/passwd)
    echo "Please type your username"
    read username
    echo "Adding user to /etc/group"
    echo "$username:x:$id:" >> /etc/group
    echo "Adding user to /etc/passwd"
    echo "$username:x:$id:$id:$username:/home/$username:/bin/bash" >> /etc/passwd
    echo "Adding user to /etc/shadow"
    echo "$username:!:19000:0:99999:7:::" >> /etc/shadow
    echo "Creating home directory"
    mkdir -p /home/$username
    chown -R "$username:$username" /home/$username
    chmod 755 -R /home/$username
    set +e
    until passwd "$username"; do
	sleep 1
    done
    set -e

# create autorun
    echo "Creating Autorun"
    printf "#!/bin/bash\n# This script will automatically run when you run launch-debian.sh" > /autorun.sh
    chmod +x /autorun.sh
