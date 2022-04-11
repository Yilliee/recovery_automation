#!/bin/bash

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r

TOOLCHAIN_PATH=$HOME/toolchain
CLANG_PATH=${TOOLCHAIN_PATH}/clang/clang-r416183b1

export PATH=${CLANG_PATH}/bin/:${TOOLCHAIN_PATH}/aarch64/:${TOOLCHAIN_PATH}/arm/:$PATH
export LD_LIBRARY_PATH=${CLANG_PATH}/lib64:$LD_LIBRARY_PATH

make ARCH=arm64 O=a51 ${DEFCONFIG} -j$(nproc --all)

make ARCH=arm64 O=a51 -j$(nproc --all) \
     CC="clang" CLANG_TRIPLE="aarch64-linux-gnu-" \
     CROSS_COMPILE="aarch64-linux-android-" \
     CROSS_COMPILE_ARM32="arm-linux-androideabi-"

