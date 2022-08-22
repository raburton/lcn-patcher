# lcn-patcher
This tool will allow you to easily modify the  underlying Linux system of certain Nissan Connect sat-nav head units, to modify the devices function.

While it is possible to gain root access to the unit over ssh, with a connected network adapter and a laptop, this is probably not ideal for most people. This tool generates filesystem images that can be written to a usb stick to automate the process, requiring no Linux skills on the part of the user. Hopefully this also reduces the risk of user error resulting in damage to the unit (but keep in mind this is always a possibility, and you use this tool entirely at your own risk!).

The method of gaining root access to the system via a usb stick was discovered by **@ea** and you'll find details of his exploit, used by this tool, [**here**](https://github.com/ea/bosch_headunit_root).

## Scripts included
- `test` - check if the root access exploit works on your device.
    - Writes out a file to the usb stick, to demonstrate the exploit works on your system.
    - A good idea to try this one (on its own) before proceeding with any others.
- `enable_sshd` - enables ssh server on the head unit.
    - You can then connect using an ASIX based usb network adapter connected to the head units usb port.
    - The ip address of the head unit is 172.17.0.1.
    - Login is *root*, with no password.
- `remove_alerts` - remove built-in speed camera alerts.
    - Gets rid of *Alerts_0913.ntq*, which cannot normally be removed.
    - Prevent duplicate camera alerts when using your own camera list and out of date warnings from 2013.
- `sd_modify_patch` - enable use of modified map data.
    - Patches the signature check that normally stops the map data on the sd card being modified. Hopefully we can then start to develop tools to modify the maps.
    - Currently supports firmware F16A, D554 & D605.
    - Makes a backup on internal storage before modifying the library.
    - See [this blog post](https://richard.burtons.org/2021/04/26/allowing-map-modifications-on-nissan-connect/) for more info.
- `sd_modify_unpatch` - undo the modify map patch.
    - Restores the backup (made by sd_modify_patch) of the patched library.

## Instructions
Run the tool (on Linux) and specify the scripts you want included in the image. Running the tool without parameters will list the available scripts. You will need to have `mke2fs` and `e2cp` tools installed (in Debian these come from packages `e2fsprogs` and `e2tools` respectively).

    ./create_image.sh enable_sshd remove_alerts

Check the output for error messages. This will produce a file called `image.ext2` which needs to be written to a usb stick. Write it with a command like this (replacing *sd#* with the appropriate device):

     dd if=./image.ext2 of=/dev/sd# bs=1M

Then simply turn on the head unit, wait a moment, and plug in the usb stick. If it works the head unit will restart after about 10 seconds. A log file `log.txt` will be written to the usb stick, you will need to mount the stick on a Linux system to read this.

The root access exploit, and the individual patches, have not been tested on all possible combinations of head unit and firmware version. It does not appear to work on Connect 1 devices. You may get a message saying the usb stick format is not supported, even if it is going to work, so wait for the reboot.

