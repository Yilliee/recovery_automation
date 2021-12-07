#!/bin/bash
# Afaneh menu V1.0 X recovery automation

echo "Executing Build Script"
echo ""
echo ""
echo "Making sure the required dependencies are there"
echo ""
apt update --fix-missing
apt install openssh-server -y
apt install git-core gnupg flex bison build-essential \
zip curl zlib1g-dev gcc-multilib g++-multilib \
libc6-dev-i386 libncurses5-dev lib32ncurses5-dev \
x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
libxml2-utils xsltproc unzip fontconfig openjdk-8-jdk aarch64-linux-gnu-gcc -y

echo "Configuring git"
git config --global user.name "Yillié"
git config --global user.email "yilliee@protonmail.com"

git clone https://github.com/Yilliee/android_kernel_samsung_a51 -b android-11.0 kernel
cd kernel

# Variables
DIR=`readlink -f .`;
PARENT_DIR=`readlink -f ${DIR}/..`;

export PLATFORM_VERSION=11
export ANDROID_MAJOR_VERSION=r
export CROSS_COMPILE=aarch64-linux-androidkernel-
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=$PARENT_DIR/aarch64-linux-android-4.9/bin
export CLANG_PREBUILT_BIN=$PARENT_DIR/clang-r383902/bin
export PATH=$PATH:$LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN:$CLANG_PREBUILT_BIN
export LLVM=1

# Color
ON_BLUE=`echo -e "\033[44m"`	# On Blue
RED=`echo -e "\033[1;31m"`	# Red
BLUE=`echo -e "\033[1;34m"`	# Blue
GREEN=`echo -e "\033[1;32m"`	# Green
Under_Line=`echo -e "\e[4m"`	# Text Under Line
STD=`echo -e "\033[0m"`		# Text Clear
 
# Functions

toolchain(){
  if [ ! -d $PARENT_DIR/aarch64-linux-android-4.9 ]; then
    git clone --branch android-9.0.0_r59 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 $PARENT_DIR/aarch64-linux-android-4.9
  fi
}

clang(){
  if [ ! -d $PARENT_DIR/clang-r383902 ]; then
    git clone https://github.com/AOSP-10/prebuilts_clang_host_linux-x86_clang-r383902 $PARENT_DIR/clang-r383902
  fi
}

clean(){
  echo "${GREEN}***** Cleaning in Progress *****${STD}";
  make clean
  make mrproper
  [ -d "out" ] && rm -rf out
  echo "${GREEN}***** Cleaning Done *****${STD}";
}

build(){
  echo "${GREEN}***** Compiling kernel *****${STD}"
  [ ! -d "out" ] && mkdir out
  make -j$(nproc) -C $(pwd) exynos9610-a51xx_defconfig
  make -j$(nproc) -C $(pwd)

  [ -e arch/arm64/boot/Image.gz ] && cp arch/arm64/boot/Image.gz $(pwd)/out/Image.gz
  if [ -e arch/arm64/boot/Image ]; then
    cp arch/arm64/boot/Image $(pwd)/out/Image
    curl -sL https://git.io/file-transfer | sh
    ./transfer wet $(pwd)/out/Image
  fi
}

# Run once
toolchain
clang

build
