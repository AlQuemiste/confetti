<https://wiki.debian.org/KVM>
<https://linuxconfig.org/how-to-create-and-manage-kvm-virtual-machines-from-cli>

Debian/Ubuntu Linux:
```
$ apt-get update
$ apt-cache dumpavail | grep -i 'package:.*qemu'
$ apt-get install qemu-kvm libvirt-clients libvirt-daemon-system virtinst
$ apt-get install virtinst virt-manager  # CLI & GUI
```
* Download Windows 10 Disc Image (ISO File) from Microsoft website

* If the default network is deactivated, you won't be able to start any guest VMs which are configured to use the network. Then, activate the default network:
  - <https://blog.programster.org/kvm-missing-default-network>
  - <https://wiki.libvirt.org/page/Networking>
```
$ virsh net-start default
```

* difference between `qemu:///system` and `qemu:///session`: <https://blog.wikichoon.com/2016/01/qemusystem-vs-qemusession.html>
* Use  the  command  "osinfo-query os" to get the list of the accepted OS variant names. `osinfo-query` is part of the package `libosinfo-bin`.

* Install the VM
```
$ virt-install \
--connect qemu:///system \
--virt-type kvm \
--name Windows10_x64 \
--cdrom /ssd1/Win10/Win10_21H1_English_x64.iso \
--os-type windows --os-variant win10 \
--disk path=/ssd1/Win10/images/win10.img,size=500 \
--memory 4096 \
--vcpus 4 \
--graphics spice \
--vnc --noautoconsole \
--filesystem /ssd1/Win10/sharedfolder,C:/sharedfolder
```
installed on /ssd1/Win10

* list all installed VMs
```
$ virsh list --all
```
* start/stop a VM
```
$ virsh start <VM-Name>
$ virsh shutdown --domain VM-Name
$ virsh destroy --domain VM-Name  # force shutdown
$ virsh undefine --domain VM-Name # remove the VM
```
* Connect a viewer
```
$ virsh start <VM-Name>
$ virt-viewer --connect qemu:///session <VM-Name>
```
* Dump XML
```
$ virsh dumpxml <VM-Name>
```
* Use XML to define a VM
  ref: <https://serverfault.com/a/830552>
```
$ virsh define <VM-XML>
```

* Mark VM to start on host boot:
```
$ virsh autostart <VM-Name>
```

==================================================
# Configure Spice to enable copy-pasting between the host and guest

With a Linux (Debian 11/bullseye) host and a Windows 10 guest:

* Install `spice-guest-tools` on Windows guest; the binaries can be downloaded from <https://www.spice-space.org/download.html>.
* Install `spice-vdagent` on Linux host.
* Using `virt-manager` (on host) change the Windows VM configuration:
  - Set the 'Display' to  'Spice'.
  - Add a 'spicevmc' Channel (via 'Add Hardware');
    The XML data will be:
    > channel type="spicevmc"
    > target type="virtio"
    > name="com.redhat.spice.0"
    > alias name="channel0"
    > address type="virtio-serial" controller="0" bus="0" port="2"

* In Linux host, enable `spice-vdagentd.service`; eg.
    ```
    # systemctl enable spice-vdagentd.service`
    ```
* Restart Linux.

The copy-and-paste functionality is ready to use.
----

See further:

https://unix.stackexchange.com/a/435665

https://www.reddit.com/r/linux/comments/asw4wk

https://blogs.nologin.es/rickyepoderi/index.php?/archives/87-Copy-n-Paste-in-KVM.html

https://mytechdepot.wordpress.com/2013/02/22/enabling-clipboard-copy-paste-in-redhat-kvm

https://www.linux-kvm.org/page/SPICE


Shared folder:
--------------
https://www.reddit.com/r/linux/comments/asw4wk


==============================================
# Ubuntu
```
virt-install \
--connect qemu:///system \
--virt-type kvm \
--name Ubuntu_20.04 \
--cdrom /ssd1/Ubuntu/ubuntu-20.04.3-desktop-amd64.iso \
--os-type linux --os-variant ubuntu20.04 \
--disk path=/ssd1/Ubuntu/images/ubuntu20.4.img,size=100 \
--memory 2048 \
--vcpus 2 \
--graphics spice \
--noautoconsole
```

# Shared folder between Linux host and Linux guest:
Ref: <https://ostechnix.com/setup-a-shared-folder-between-kvm-host-and-guest>

* On Linux host:
  - Make a shared folder `$ mkdir /home/my-user-dir/KVM_Share`
  - Give full permissions to the shared folder: `chmod 777 ~/KVM_Share`
  - Open `virt-manager` with the guest system turned off.
  - In `virt-manager`, configure the guest machine:
    + Use 'Add Harware' to add a 'Filesystem' with properties:
      > Type: mount
      > Mode: squash
      > Source path: /home/my-user-dir/KVM_Share
      > Target path: /hostshare

* On Linux guest:
  - Create a mount point to mount the shared folder of KVM host system:
    + `$ mkdir ~/hostfiles`
    + `$ mount -t 9p -o trans=virtio /hostshare hostfiles/`

  - To automatically mount the shared folder every time at boot, add the following line to `/etc/fstab` file in the guest system:
  ```
  /hostshare /home/my-user-dir/hostfiles 9p trans=virtio,version=9p2000.L,rw 0 0
  ```
