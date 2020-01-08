#bin/bash

echo -n 0000:28:00.2 > /sys/bus/pci/devices/0000:28:00.2/driver/unbind
echo -n 0000:1a:00.2 > /sys/bus/pci/devices/0000:1a:00.2/driver/unbind
echo -n 0000:6e:00.2 > /sys/bus/pci/devices/0000:6e:00.2/driver/unbind
echo -n 0000:60:00.2 > /sys/bus/pci/devices/0000:60:00.2/driver/unbind
echo -n 0000:bf:00.2 > /sys/bus/pci/devices/0000:bf:00.2/driver/unbind
echo -n 0000:28:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:1a:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:6e:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:60:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
echo -n 0000:bf:00.2 > /sys/bus/pci/drivers/vfio-pci/bind

vmname="Windows10provm"

if ps -ef | grep qemu-system-x86_64 | grep -q multifunction=on; then
echo "A passthrough VM is already running." &
exit 1

else

# use pulseaudio
export QEMU_AUDIO_DRV=none
#export QEMU_AUDIO_DRV=pa
#export QEMU_PA_SAMPLES=8192
#export QEMU_AUDIO_TIMER_PERIOD=99
#export QEMU_PA_SERVER=/run/user/1000/pulse/native

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
-device pcie-root-port,bus=pcie.0,addr=17.0,multifunction=on,port=0,chassis=5,id=root.1,pref64-reserve=32M \
-device x3130-upstream,id=upstream_port1.1,bus=root.1 \
-device xio3130-downstream,id=downstream_port1.1,bus=upstream_port1.1,chassis=0 \
-device xio3130-downstream,id=downstream_port1.2,bus=upstream_port1.1,chassis=1 \
-device xio3130-downstream,id=downstream_port1.3,bus=upstream_port1.1,chassis=2 \
-device xio3130-downstream,id=downstream_port1.4,bus=upstream_port1.1,chassis=3 \
-device xio3130-downstream,id=downstream_port1.5,bus=upstream_port1.1,chassis=4 \
-device vfio-pci,host=28:00.0,bus=downstream_port1.1,addr=0x00,multifunction=on \
-device vfio-pci,host=28:00.1,bus=downstream_port1.1,addr=0x00.1 \
-device vfio-pci,host=28:00.2,bus=downstream_port1.1,addr=0x00.2 \
-device vfio-pci,host=28:00.3,bus=downstream_port1.1,addr=0x00.3 \
-device vfio-pci,host=1a:00.0,bus=downstream_port1.2,addr=0x00,multifunction=on \
-device vfio-pci,host=1a:00.1,bus=downstream_port1.2,addr=0x00.1 \
-device vfio-pci,host=1a:00.2,bus=downstream_port1.2,addr=0x00.2 \
-device vfio-pci,host=1a:00.3,bus=downstream_port1.2,addr=0x00.3 \
-device vfio-pci,host=6e:00.0,bus=downstream_port1.3,addr=0x00,multifunction=on \
-device vfio-pci,host=6e:00.1,bus=downstream_port1.3,addr=0x00.1 \
-device vfio-pci,host=6e:00.2,bus=downstream_port1.3,addr=0x00.2 \
-device vfio-pci,host=6e:00.3,bus=downstream_port1.3,addr=0x00.3 \
-device vfio-pci,host=60:00.0,bus=downstream_port1.4,addr=0x00,multifunction=on \
-device vfio-pci,host=60:00.1,bus=downstream_port1.4,addr=0x00.1 \
-device vfio-pci,host=60:00.2,bus=downstream_port1.4,addr=0x00.2 \
-device vfio-pci,host=60:00.3,bus=downstream_port1.4,addr=0x00.3 \
-device vfio-pci,host=bf:00.0,bus=downstream_port1.5,addr=0x00,multifunction=on \
-device vfio-pci,host=bf:00.1,bus=downstream_port1.5,addr=0x00.1 \
-device vfio-pci,host=bf:00.2,bus=downstream_port1.5,addr=0x00.2 \
-device vfio-pci,host=bf:00.3,bus=downstream_port1.5,addr=0x00.3 \
-drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/tmp/my_vars.fd \
-boot order=dc \
-drive id=disk0,if=virtio,cache=none,format=raw,file=/home/viavm/iso/win10.img \

exit 0
fi
