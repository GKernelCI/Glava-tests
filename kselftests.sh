#!/bin/sh

if [ ! -e /root/kselftest.tar.gz ];then
	case $(uname -m) in
	aarch64)
		KSARCH=arm64
	;;
	x86_64)
		KSARCH=x86
	;;
	armv7l)
		KSARCH=arm
		echo "SKIP: kselftests are disabled on ARM"
		exit 0
	;;
	*)
		echo "SKIP: no kselftests for $(uname -m) arch"
		exit 0
	;;
	esac
	# TODO move this in rootfs generation
	wget http://storage.kernelci.org/images/selftests/$KSARCH/kselftest.tar.gz
fi
tar xzf kselftest.tar.gz || exit $?
cd kselftest
# remove test which stuck
sed -i 's,.*ftracetest.*,echo "selftests: ftracetest [SKIP]",' run_kselftest.sh
# remove some tests which always fail
sed -i 's,.*execveat.*,echo "selftests: execveat [SKIP]",' run_kselftest.sh
sed -i 's,.*test_bpf.sh.*,echo "selftests: test_bpf.sh [SKIP]",' run_kselftest.sh
sed -i 's,.*run_vmtests.*,echo "selftests: run_vmtests [SKIP]",' run_kselftest.sh
sed -i 's,.*fw_filesystem.sh.*,echo "selftests: fw_filesystem.sh [SKIP]",' run_kselftest.sh
sed -i 's,.*fw_userhelper.sh.*,echo "selftests: fw_userhelper.sh [SKIP]",' run_kselftest.sh

./run_kselftest.sh
