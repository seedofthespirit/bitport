# Build A Custom Debian Live system for Electrum Wallet

We will build our Debian live system following an excellent guide for creating a bootable system at
[Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html).


We are using a Debian host to build a live system.


## Download the latest Electrum source code from the official site

The official URL of Electrum is `https://www.electrum.org/#download`.
Before downloading read the instructions there.

As described on the Electrum download page
its Linux version depends on the packages:
python3-pyqt5, libsecp256k1-dev, python3-cryptography.
We are going to include these packages in the live build later.

Create a directory for Electrum and download it together with the cryptographic signature file.
```
xyz@debian:~$ mkdir Electrum
xyz@debian:~$ cd Electrum
xyz@debian:~/Electrum$ wget https://download.electrum.org/4.5.5/Electrum-4.5.5.tar.gz
...
xyz@debian:~/Electrum$ wget https://download.electrum.org/4.5.5/Electrum-4.5.5.tar.gz.asc
...
xyz@debian:~/Electrum$ ls -l Electrum-4.5.5*
-rw-r--r-- 1 xyz xyz 13162562 May 30 03:00 Electrum-4.5.5.tar.gz
-rw-r--r-- 1 xyz xyz     2499 May 30 03:00 Electrum-4.5.5.tar.gz.asc
xyz@debian:~/Electrum$ 
```

Before verification you would need to import the public key that corresponds to the signing key.
They post their public keys at `https://raw.githubusercontent.com/` so you can import these keys,
but you can also import them from well-known public key servers.
```
xyz@debian:~/Electrum$ 
xyz@debian:~/Electrum$ /usr/bin/gpg --keyserver pool.sks-keyservers.net --recv-keys 2BD5824B7F9470E6
...
xyz@debian:~/Electrum$ 
```

Now you can verify authenticity of the downloaded file via gpg.
```
xyz@debian:~/Electrum$ gpg --verify Electrum-4.5.5.tar.gz.asc Electrum-4.5.5.tar.gz
gpg: Signature made Thu May 30 02:49:28 2024 PDT
gpg:                using RSA key 637DB1E23370F84AFF88CCE03152347D07DA627C
gpg: Good signature from "Stephan Oeste (it) <it@oeste.de>" [unknown]
gpg:                 aka "Emzy E. (emzy) <emzy@emzy.de>" [unknown]
gpg:                 aka "Stephan Oeste (Master-key) <stephan@oeste.de>" [unknown]
gpg: Note: This key has expired!
Primary key fingerprint: 9EDA FF80 E080 6596 04F4  A76B 2EBB 056F D847 F8A7
     Subkey fingerprint: 637D B1E2 3370 F84A FF88  CCE0 3152 347D 07DA 627C
gpg: Signature made Thu May 30 02:24:30 2024 PDT
gpg:                using RSA key 0EEDCFD5CAFB459067349B23CA9EEEC43DF911DC
gpg: Good signature from "SomberNight/ghost43 (Electrum RELEASE signing key) <somber.night@protonmail.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 0EED CFD5 CAFB 4590 6734  9B23 CA9E EEC4 3DF9 11DC
gpg: Signature made Wed May 29 22:36:00 2024 PDT
gpg:                using RSA key 6694D8DE7BE8EE5631BED9502BD5824B7F9470E6
gpg: Good signature from "Thomas Voegtlin (https://electrum.org) <thomasv@electrum.org>" [unknown]
gpg:                 aka "ThomasV <thomasv1@gmx.de>" [unknown]
gpg:                 aka "Thomas Voegtlin <thomasv1@gmx.de>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 6694 D8DE 7BE8 EE56 31BE  D950 2BD5 824B 7F94 70E6
xyz@debian:~/Electrum$ 
xyz@debian:~/Electrum$ cd ..
xyz@debian:~$ 
```


## Install live-build system on the build host

Debian has the package live-build so we can simply install it:
```
xyz@debian:~$ sudo apt-get install live-build
```

## Modify some of live-build config files on the host (Optional)

### Disable beep sound at the grub boot menu

To disable the annoying loud beep sound at the grub boot menu in the live system
we have to disable it in the host system first because
the live system config file will be copied from the host system.

Modify `/usr/share/live/build/bootloaders/grub-pc/config.cfg` in the host.

```
xyz@debian:~$ diff -Naur /usr/share/live/build/bootloaders/grub-pc/config.cfg_original /usr/share/live/build/bootloaders/grub-pc/config.cfg
--- /usr/share/live/build/bootloaders/grub-pc/config.cfg_original	2023-05-02 05:30:24.000000000 -0700
+++ /usr/share/live/build/bootloaders/grub-pc/config.cfg	2024-06-30 19:59:06.110529579 -0700
@@ -27,4 +27,4 @@
 terminal_output gfxterm
 
 insmod play
-play 960 440 1 0 4 440 1
+#play 960 440 1 0 4 440 1
xyz@debian:~$ 
```

## Create a working directory for building a live system
```
xyz@debian:~$ mkdir live-build-work
```

## Generate build configuration files

Move to the working directory and run the command `lb config`:
```
xyz@debian:~$ cd live-build-work
xyz@debian:~/live-build-work$ 
xyz@debian:~/live-build-work$ lb config
```

This will generate the sub-directories auto, config and local.
```
xyz@debian:~/live-build-work$ ls -la
total 24
drwxr-xr-x  6 xyz xyz 4096 Jun 30 20:04 .
drwxr-xr-x  3 xyz xyz 4096 Jun 30 19:48 ..
drwxr-xr-x  2 xyz xyz 4096 Jun 30 20:04 .build
drwxr-xr-x  2 xyz xyz 4096 Jun 30 20:04 auto
drwxr-xr-x 20 xyz xyz 4096 Jun 30 20:04 config
drwxr-xr-x  3 xyz xyz 4096 Jun 30 20:04 local
xyz@debian:~/live-build-work$ 
```

All customizations are done with files in auto and config directories.
Copy the skeleton auto scripts from `/usr/share/doc/live-build/examples/auto/` to `./auto`.
```
xyz@debian:~/live-build-work$ cp /usr/share/doc/live-build/examples/auto/* ./auto/
xyz@debian:~/live-build-work$ ls -la auto/
total 20
drwxr-xr-x 2 xyz xyz 4096 Jun 30 20:14 .
drwxr-xr-x 6 xyz xyz 4096 Jun 30 20:04 ..
-rwxr-xr-x 1 xyz xyz   63 Jun 30 20:14 build
-rwxr-xr-x 1 xyz xyz  138 Jun 30 20:14 clean
-rwxr-xr-x 1 xyz xyz   46 Jun 30 20:14 config
xyz@debian:~/live-build-work$ 
```

## Customize the configuration setting under auto

Now edit auto/config as follows:

```
xyz@debian:~/live-build-work$ cat auto/config
#!/bin/sh

set -e

lb config noauto \
    --architectures amd64 \
    --distribution bookworm \
    --archive-areas "main non-free-firmware contrib non-free" \
    --binary-images iso-hybrid \
    --debian-installer none \
    --apt-indices false \
    --apt-source-archives false \
    "${@}"
xyz@debian:~/live-build-work$ 
```

In case the platform is not regular PC the architecture `amd64` above needs to be replaced with the proper platform value.

After editing auto/config run the following command again to make the changes in auto/config take effects:
```
xyz@debian:~/live-build-work$ lb config
xyz@debian:~/live-build-work$ 
```

## Customize the Debian packages to include in the live image

Add package names in `config/package-lists/my.list.chroot` one package per line.
The file name `my.list.chroot` can be anything if it ends with `.list.chroot`,
which is the convention the live-build system relies on to pick up relevant configuration files.

The packages included there and their dependency packages will be installed in the directory `./chroot/`
along with all necessary files for booting the live system,
and eventually included in the `live/filesystem.squashfs`.

When using Electrum in the cold storage wallet setting we never want to enable networks or background activities unrelated to Electrum on its Debian Live system.
So it is better to keep the package set minimal for the live system.
For example I use the following packages which don't pull any networking packages as their dependencies.
You can add other packages that don't require network connection.

```
xyz@debian:~/live-build-work$ cat config/package-lists/my.list.chroot
xfdesktop4
xfce4
xfce4-session
xfwm4
xfce4-terminal
xfce4-panel
xfce4-battery-plugin
xfce4-clipman
xfce4-clipman-plugin
xfce4-cpufreq-plugin
xfce4-cpugraph-plugin
xfce4-datetime-plugin
xfce4-dict
xfce4-power-manager
xfce4-power-manager-plugins
xfce4-screenshooter
xfce4-sensors-plugin
xfce4-taskmanager
xfce4-xkb-plugin
xinit
thunar
lightdm
vim
mousepad
ristretto
eog
feh
mupdf
sudo
man-db
manpages
yad
bash
p7zip-full
bzip2
zip
unzip
file
python3-pyqt5
python3-cryptography
libsecp256k1-1
libsecp256k1-dev
zbar-tools
cryptsetup-bin
libcryptsetup12
libblockdev-crypto2
gpg
gpgconf
gpg-agent
pinentry-gtk2
paperkey
diceware
xyz@debian:~/live-build-work$ 
```

Optionally it would be helpful to have the following packages as well if you want to program Yubikey devices on an offline computer.

```
keepassxc
yubikey-manager
yubikey-personalization
yubico-piv-tool
openssl
openssh-client
opensc
pcsc-tools
pcscd
scdaemon
```

You should delete backup files such as `my.list.chroot~` in the directory `config/package-lists/`
to avoid them getting included by `lb build` command.

## Customize non-package files to include

Non-package files means they are not part of the Debian packages.
For example the latest Electrum is usually not part of the Debian packages.
To include non-package files in the live system
we can either copy non-package files under the directory `config/includes.chroot_after_packages`
or create new Debian packages and install them.
Creating new Debian packages and making them installed with live-build take a significant effort,
and we would have to repeat the process when we want to update the packages in response to
the updates from the original providers.
We are going to use the first method of installing non-package files in `config/includes.chroot_after_packages`

### Electrum and its wrapper scripts

We have already included the Electrum dependency packages python3-pyqt5, libsecp256k1-dev, python3-cryptography in
`config/package-lists/my.list.chroot`

We now install Electrum under `./config/includes.chroot_after_packages/`
```
xyz@debian:~/live-build-work$ 
xyz@debian:~/live-build-work$ mkdir -p ./config/includes.chroot_after_packages/opt/electrum
xyz@debian:~/live-build-work$ tar xf ~/Electrum/Electrum-4.5.5.tar.gz -C ./config/includes.chroot_after_packages/opt/electrum/
```

Also install our Electrum wrapper scripts:
```
xyz@debian:~/live-build-work$ mkdir -p ./config/includes.chroot_after_packages/opt/electrum/wrapper
xyz@debian:~/live-build-work$ cp ~/Electrum/Bitport/bitport/wrapper/* ./config/includes.chroot_after_packages/opt/electrum/wrapper
```

### Wrapper launchers

Copy wrapper launchers:
```
xyz@debian:~/live-build-work$ mkdir -p ./config/includes.chroot_after_packages/usr/local/share/applications/
xyz@debian:~/live-build-work$ cp ~/Electrum/Bitport/bitport/launcher/*.desktop ./config/includes.chroot_after_packages/usr/local/share/applications
xyz@debian:~/live-build-work$ mkdir -p ./config/includes.chroot_after_packages/usr/local/share/icons/
xyz@debian:~/live-build-work$ cp ./config/includes.chroot_after_packages/opt/electrum/Electrum-4.1.5/electrum/gui/icons/electrum.png ./config/includes.chroot_after_packages/usr/local/share/icons/
xyz@debian:~/live-build-work$ 
```

## Customize the live user configurations

Add the default account `user` in the groups: audio cdrom dip video plugdev lpadmin scanner sudo.

```
xyz@debian:~/live-build-work$ mkdir -p ./config/includes.chroot_after_packages/etc/live/config.conf.d/
xyz@debian:~/live-build-work$ echo 'LIVE_USER_DEFAULT_GROUPS="audio cdrom dip video plugdev lpadmin scanner sudo"' > ./config/includes.chroot_after_packages/etc/live/config.conf.d/10-user-setup.conf
xyz@debian:~/live-build-work$ 
```

BTW, the default password for the default account `user` is `live` and we will use it as it is.

## Customize system configurations (Optional except for 0073-disable-network.hook.chroot)

Add some (or all) of the following custom configuration files into ./config/hooks/live/ directory.

* 0070-edit-xsettings.hook.chroot to disable blinking cursor.
* 0071-disable-bell.hook.chroot to disable bell in terminal.
* 0072-set-xkb.hook.chroot to map CapsLock key to Control.
* 0073-disable-network.hook.chroot to disable network manager from getting started via systemctl.
* 0074-udisks2-mount-noatime.hook.chroot to let udisks2 mount any device with noatime.

You definitely need to take `0073-disable-network.hook.chroot` but can skip others if you prefer the system default instead of these.

```
xyz@debian:~/live-build-work$ cp ~/Electrum/Bitport/bitport/hooks/live/* ./config/hooks/live/
xyz@debian:~/live-build-work$ 
```

## Run live-build to build an ISO-9660 image

We are ready to start building.
Note that throughout this process you need network connection to download required Debian packages.
It could take more than an hour.

```
xyz@debian:~/live-build-work$ sudo lb build
```

Toward the end of this command it will run `mksquashfs` which is very CPU intensive.
In my case I used `cpulimit` to throttle down CPU usage of the `mksquashfs` process to avoid overheating my computer.
In my another terminal different from the one lb build is going on:
```
xyz@debian:~/live-build-work$ ps aux | grep squashfs | grep -v grep
root      112212  364  3.3 2027844 538708 pts/1  SNl+ 21:47   0:20 mksquashfs chroot filesystem.squashfs -comp xz
xyz@debian:~/live-build-work$ sudo cpulimit -p 112212 -l 35
[sudo] password for xyz: 
Process 112212 detected
...
```

When encountering any error `lb build` will save the current build state and unwind the build before exiting so that
you can repeat the build command after correcting the reported error possibly originating in a wrong configuration under config/.
The command `lb clean` will clean the build directory but will not delete the already configured files under `./auto/` and `./config/`.

If everything works it will generate a bootable ISO-9660 image `live-image-amd64.hybrid.iso`.
This name itself isn't particularly informative, so it is best to rename it to something easier to identify.
We will address this in the next section.

```
...
P: Build completed successfully
xyz@debian:~/live-build-work$ echo $?
0
xyz@debian:~/live-build-work$ ls -la
total 1263640
drwxr-xr-x  9 xyz   xyz         4096 Jul  4 22:38 .
drwxr-xr-x  3 xyz   xyz         4096 Jul  4 22:49 ..
drwxr-xr-x  2 xyz   xyz         4096 Jul  4 22:38 .build
drwxr-xr-x  2 xyz   xyz         4096 Jul  3 21:26 auto
drwxr-xr-x  7 root  root        4096 Jul  4 21:40 binary
-rw-r--r--  1 root  root         958 Jul  4 22:37 binary.modified_timestamps
-rw-r--r--  1 root  root      798313 Jul  4 22:38 build.log
drwxr-xr-x  7 root  root        4096 Jul  4 21:40 cache
drwxr-xr-x 17 root  root        4096 Jul  4 22:38 chroot
-rw-r--r--  1 root  root     5018862 Jul  4 21:46 chroot.files
-rw-r--r--  1 root  root       30400 Jul  4 21:45 chroot.packages.install
-rw-r--r--  1 root  root       30400 Jul  4 21:46 chroot.packages.live
drwxr-xr-x 20 xyz   xyz         4096 Jul  4 21:40 config
-rw-r--r--  1 root  root       18087 Jul  4 22:37 live-image-amd64.contents
-rw-r--r--  1 root  root     5018862 Jul  4 21:46 live-image-amd64.files
-rw-r--r--  1 root  root  1277968384 Jul  4 21:40 live-image-amd64.hybrid.iso
-rw-r--r--  1 root  root     4992291 Jul  4 22:38 live-image-amd64.hybrid.iso.zsync
-rw-r--r--  1 root  root       30400 Jul  4 21:46 live-image-amd64.packages
drwxr-xr-x  3 root  root        4096 Jul  4 21:40 local
xyz@debian:~/live-build-work$ 
```

If the `lb build` command failed it is better to run `sudo lb clean` otherwise re-running `lb build` will probably fail again.
For example, when I specified a non-existing package within ./config/package-lists/my.list.chroot it failed as expected,
but the next run of `lb build` even after correcting the package list led to a different error of missing chroot/boot/vmlinuz-*.


## Test the ISO-9660 image with VirtualBox

Create a new virtual machine within VirtualBox,
assign `live-image-amd64.hybrid.iso` (or the one with the customized name you will create in the next Install step)
to the CD/DVD drive file under Controller IDE storage devices
in the storage tab, and start the virtual machine.


## References

+ [Debian Live Development Documentation](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)

+ [Official Electrum site with the download and instruction links](https://www.electrum.org)

