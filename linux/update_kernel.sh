#!/bin/bash -eu
#
# Download and build linux using "config", the configuration suitable for
# our virtualized tests. Install the bzImage as "kernel" in the current
# directory.
#
# Set the LINUX_URL environment variable to download from a different location.
#
# Set the MENUCONFIG environment variable to adapt the configuration
# interactively before compilation.
#
# The LINUX_DL environment variable can be used to override the download
# command. It may be set to any alternative command that produces an
# XZ-compressed kernel tarball, e.g.:
#
#    LINUX_DL="cat $HOME/Download/linux-6.6.1.tar.xz" ./update_kernel.sh

BUILD_DIR=$(mktemp -d)
BASE_DIR=$(dirname $(realpath $0))

trap "rm -rf ${BUILD_DIR}" ERR EXIT

CONFIG=${BASE_DIR}/config
OUTFILE=${BASE_DIR}/kernel

: ${LINUX_URL:="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.1.tar.xz"}
: ${LINUX_DL:=wget -O- ${LINUX_URL}}
: ${MENUCONFIG:=""}

# Download and extract
${LINUX_DL} | tar --extract --xz --strip-components=1 --directory=${BUILD_DIR} -f -

# Build
cp ${CONFIG} ${BUILD_DIR}/.config
make -C ${BUILD_DIR} ARCH=x86_64 olddefconfig

if [ -n "${MENUCONFIG}" ];
then
    make -C ${BUILD_DIR} ARCH=x86_64 menuconfig
fi

make -C ${BUILD_DIR} ARCH=x86_64 -j$(nproc)

# Sanitize and store new configuration
grep -v "^\(#.*\|CONFIG_\(G\?CC\|CLANG\|AS\|L\?LD\)_.*\|\)$" ${BUILD_DIR}/.config > ${CONFIG} 

# Install result
install ${BUILD_DIR}/arch/x86_64/boot/bzImage ${OUTFILE}
