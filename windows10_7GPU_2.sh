#!/bin/bash
echo -n 0000:28:00.2 > /sys/bus/pci/devices/0000:28:00.2/driver/unbind
echo -n 0000:1a:00.2 > /sys/bus/pci/devices/0000:1a:00.2/driver/unbind
echo -n 0000:6e:00.2 > /sys/bus/pci/devices/0000:6e:00.2/driver/unbind
echo -n 0000:60:00.2 > /sys/bus/pci/devices/0000:60:00.2/driver/unbind
echo -n 0000:bf:00.2 > /sys/bus/pci/devices/0000:bf:00.2/driver/unbind
echo -n 0000:b1:00.2 > /sys/bus/pci/devices/0000:b1:00.2/driver/unbind
echo -n 0000:96:00.2 > /sys/bus/pci/devices/0000:96:00.2/driver/unbind
echo -n 0000:28:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:1a:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:6e:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:60:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:bf:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:b1:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:96:00.2 > /sys/bus/pci/drivers/vfio-pci/bind

vmname="Windows10provm"

if ps -ef | grep qemu-system-x86_64 | grep -q multifunction=on; then
echo "A passthrough VM is already running." &
exit 1

else

# use pulseaudio
export QEMU_AUDIO_DRV=pa
export QEMU_PA_SAMPLES=8192
export QEMU_AUDIO_TIMER_PERIOD=99
export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd

qemu-system-x86_64 \
-name $vmname,process=$vmname \
-machine type=q35,accel=kvm \
-cpu host,kvm=off \
-smp 32,sockets=2,cores=8,threads=2 \
-m 64G \
-balloon none \
-rtc clock=host,base=localtime \
-vga none \
-nographic \
-serial none \
-parallel none \
-soundhw hda \
-usb \
-device usb-host,vendorid=0x093a,productid=0x2510 \
-device usb-host,vendorid=0x0b38,productid=0x0010 \
-device pcie-root-port,bus=pcie.0,addr=17.0,multifunction=on,port=0,chassis=7,id=root.1,pref64-reserve=32M \
-device vfio-pci,host=28:00.0,bus=root.1,addr=0x00.0,multifunction=on \
-device vfio-pci,host=28:00.1,bus=root.1,addr=0x00.1 \
-device vfio-pci,host=28:00.2,bus=root.1,addr=0x00.2 \
-device vfio-pci,host=28:00.3,bus=root.1,addr=0x00.3 \
-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/tmp/my_vars.fd \
-boot order=dc \
-drive id=disk0,if=virtio,cache=none,format=raw,file=/home/vm/iso/win10.img \
-drive file=/home/vm/iso/Win10.iso,index=1,media=cdrom \
-drive file=/home/vm/iso/virtio-win-0.1.171.iso,index=2,media=cdrom \

exit 0
fi

