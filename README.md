# vpp_demos
A repo full of VPP demos I did with Docker and netns in an Ubuntu 18.04 VM. It was performed on Mac OS X with VMware Fusion.

I changed my VMs second NIC to vmxnet3. To change a NIC from e1000 to vmxnet3:
- `vim /path/to/vmware.vmwarevm/*.vmx` and s/e1000/vnxnet3/g
- I left my oob interface to be e1000 so that it was harder to kill all the boxes network (as I like to SSH to configure)

## Default vpp Ubuntu conf change
- All I did was add the PCI device + some memory
```
dpdk {
        socket-mem 1024
        dev 0000:03:00.0
}
```

## Requirements
- Host with docker installed
- vpp installed for your platform with an external interface
- If it does not map to *GigabitEthernet3/0/0* please change in cli.conf files

## Configure VM for vmxnet3 to be passed to VPP
- Use `lspci -nnk` to find out your PCI Hardware IDs and Addresses
  - Remember Linux and fun naming differences that *can* for PCI hardware

```
echo "vfio-pci" >> /etc/modules
echo "options vfio-pci ids=15ad:07b0" > /etc/modprobe.d/vfio-pci.conf
echo -e "# No VMWare autoloaded\nblacklist vmxnet3" >> /etc/modprobe.d/blacklist.conf
echo "options vfio enable_unsafe_noiommu_mode=1" > /etc/modprobe.d/vfio-noiommu.conf
```

- I found to actually blacklist `vmxnet3` I had to do it via Grub
  - `vim /etc/default/grub`
```
GRUB_CMDLINE_LINUX_DEFAULT="... modprobe.blacklist=vmxnet3"
```
