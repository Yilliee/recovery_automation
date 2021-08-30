#!/bin/bash

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
libxml2-utils xsltproc unzip fontconfig openjdk-8-jdk -y

echo "Installing the repo launcher"
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
echo ""

echo "Configuring git"
git config --global user.name "Yillié"
git config --global user.email "yilliee@protonmail.com"
echo "Installed all the dependecies"
echo ""
echo ""

echo "Syncing TWRP-9 Sources"
mkdir ~/twrp-9
cd ~/twrp-9
repo init https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0 --depth=1
repo sync -j $(nproc --all)
echo ""

echo "Cloning trees"
cd ~/twrp-9
git clone https://github.com/yilliee/recovery_on5xelte -b android-9.0 ~/twrp-9/device/samsung/on5xelte
git clone https://github.com/yilliee/android_kernel_samsung_on5xelte -b android-8.1 kernel/samsung/on5xelte
git clone https://github.com/lineageos/android_hardware_samsung -b lineage-16.0 ~/twrp-9/hardware/samsung
echo ""

echo "Starting Build"
cd ~/twrp-9
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch omni_on5xelte-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/twrp-9/out/target/product/*
version=$(cat ~/twrp-9/bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
version=$(echo $version | cut -c1-5)

mv recovery.img TWRP-${version}-on5xelte-$(date "+%Y%m%d").img
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls TWRP*.img
