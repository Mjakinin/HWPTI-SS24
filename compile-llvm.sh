#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 SOURCE-FILE.c"
    exit 2
fi

SRC="$1"
STARTUP="ARM_STARTUP.S"

LLVM_SUFFIX=""
SIZE=128

if [ ! -f "$SRC" ]; then
    echo "Source file \"$SRC\" not found!"
    exit 2
fi
if [ ! -f "$STARTUP" ]; then
    echo "Startup file \"$STARTUP\" not found!"
    exit 2
fi

if ! clang${LLVM_SUFFIX} --version > /dev/null ; then
    echo "clang${LLVM_SUFFIX} not found!"
    exit 2
fi
if ! ld.lld${LLVM_SUFFIX} --version > /dev/null ; then
    echo "ld.lld${LLVM_SUFFIX} not found!"
    exit 2
fi
if ! llvm-objcopy${LLVM_SUFFIX} --version > /dev/null ; then
    echo "llvm-objcopy${LLVM_SUFFIX} not found!"
    exit 2
fi
if ! dd --version > /dev/null ; then
    echo "dd not found!"
    exit 2
fi

set -e
set -o xtrace

WORKDIR=$(mktemp -d)

cat - > "${WORKDIR}/script" <<EOF
SECTIONS
{
    .text :
    {
        *(.text)
        *(.rodata.*)
        *(.rodata)
        *(.data)
    }
}
EOF

clang${LLVM_SUFFIX} -o "${WORKDIR}/ARM_MAIN.o" -nodefaultlibs -ffreestanding -mfloat-abi=soft -mlittle-endian -target arm9 -Os -fomit-frame-pointer -c "$SRC"
clang${LLVM_SUFFIX} -o "${WORKDIR}/ARM_STARTUP.o" -nodefaultlibs -ffreestanding -mfloat-abi=soft -mlittle-endian -target arm9 -Os -fomit-frame-pointer -c ARM_STARTUP.S
ld.lld${LLVM_SUFFIX} --Ttext 0 -T "${WORKDIR}/script" "${WORKDIR}/ARM_STARTUP.o" "${WORKDIR}/ARM_MAIN.o" -o "${WORKDIR}/a.out"
llvm-objcopy${LLVM_SUFFIX} --set-start 0 -j .text -j .rodata -j reprog -O binary "${WORKDIR}/a.out" "${WORKDIR}/a.bin"

output_size=$(stat -c%s "${WORKDIR}/a.bin")
if [[ "$output_size" -gt "$SIZE" ]]; then
    set +o xtrace
    echo "Program size is too large. It is $output_size, but must at max be $SIZE."
    echo "Please adjust ARM_PROG_MEM_SIZE in ArmConfiguration.vhd and SIZE in this script to a higer value to continue."
    exit 2
fi

dd if=/dev/zero of="$SRC.bin" bs=$SIZE count=1
dd if="${WORKDIR}/a.bin" of="$SRC.bin" conv=notrunc

rm -r "${WORKDIR}"

set +o xtrace
echo "Build successful."
echo "The output is located at \"$SRC.bin\"."
