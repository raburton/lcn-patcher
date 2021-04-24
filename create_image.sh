#!/bin/bash

SCRIPT=./patch_script
IMAGE=./image.ext2
PATH=$PATH:/sbin

if [ "$1" = "" ]; then
    echo "Usage: $0 [patch_script]..."
    echo "Create a filesystem image containing the specified patch"
    echo "script(s), for use on a compatible Nissan Connect device."
    echo
    echo "Available scripts are:"
    echo
    ls -1 patches
    echo
    echo "Use entirely at your own risk."
    echo
    exit
fi

echo "#!/bin/bash" >$SCRIPT
echo "MOUNTPATH=/usr/bin" >>$SCRIPT
echo "LOGFILE=\$MOUNTPATH/log.txt" >>$SCRIPT
echo "mount -o remount,rw \$MOUNTPATH" >>$SCRIPT
echo "exec >>\$LOGFILE 2>&1" >>$SCRIPT
echo "echo -n \"Date: \"" >>$SCRIPT
echo "date" >>$SCRIPT

for var in "$@"
do
    echo "Adding script: $var"
    echo "echo \"--------------------\"" >>$SCRIPT
    cat patches/$var >>$SCRIPT
done

echo "echo \"--------------------\"" >>$SCRIPT
echo "sync" >>$SCRIPT
echo "sync" >>$SCRIPT
echo "reboot" >>$SCRIPT
echo >>$SCRIPT

# root access hack, and code below, from https://github.com/ea/bosch_headunit_root
echo "You can review the completed patch script in $SCRIPT"
echo
echo "Creating filesystem..."
echo
dd if=/dev/zero of=$IMAGE bs=1024 count=8192
mke2fs $IMAGE -U 00000000-0000-0000-0000-000000000000 -L "../../usr/bin/"
e2cp -P 755 $SCRIPT $IMAGE:/logger

echo "File system created. Write to usb drive with:"
echo "dd if=$IMAGE of=/dev/sd# bs=1M"
echo "Replace sd# with your actual usb drive."
echo "Use entirely at your own risk."

