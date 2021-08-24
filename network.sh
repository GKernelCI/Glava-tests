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

# assume only one network card
ETH=$(ls /sys/class/net |grep -E 'eth|enp')

if [ -z "$ETH" ];then
	echo "WARN: no network card found"
else
	echo "INFO: configure network card $ETH"
	ln -s /etc/init.d/net.lo /etc/init.d/net.$ETH
	/etc/init.d/net.$ETH start
fi
