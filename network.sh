#!/bin/sh

echo "DEBUG: gentoo network test"

# if we have booted with either NFS or NBD, DONT TOUCH NETWORK
grep -q nfsroot /proc/cmdline
if [ $? -eq 0 ];then
	echo "INFO: we use a NFS root, do not touch network"
	exit 0
fi

grep -q nbd.server /proc/cmdline
if [ $? -eq 0 ];then
	echo "INFO: we use a NBD root, do not touch network"
	exit 0
fi

if grep -q 'ip=dhcp' /proc/cmdline;then
	echo "INFO: kernel already get an IP via ip=dhcp cmdline"
	# update resolv.conf from what got kernel
	grep nameserver /proc/net/pnp > /etc/resolv.conf
	chmod 644 /etc/resolv.conf
	exit 0
fi

# TODO we need a DHCP client to succeed next step
# but for the moment all boot will be with ip=dhcp so we do need it yet
# emerge -v busybox

# assume only one network card
ETH=$(ls /sys/class/net |grep -E 'eth|enp')

if [ -z "$ETH" ];then
	echo "WARN: no network card found"
else
	echo "INFO: configure network card $ETH"
	ln -s /etc/init.d/net.lo /etc/init.d/net.$ETH
	/etc/init.d/net.$ETH start
fi
