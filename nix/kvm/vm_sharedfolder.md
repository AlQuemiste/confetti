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
