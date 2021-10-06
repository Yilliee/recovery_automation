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

echo "Syncing TWRP-10 Sources"
mkdir ~/twrp-10
cd ~/twrp-10
repo init https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-10.0 --depth=1
repo sync -j $(nproc --all)
cd ~/twrp-10/bootable/recovery
git fetch https://github.com/Yilliee/fox_bootable_recovery 10.0_2
git cherry-pick b2a046cefabf42c3a201622cc6560d138e0fbb32
echo ""

echo "Cloning trees"
cd ~/twrp-10
git clone https://github.com/yilliee/recovery_RMX2001 -b twrp-10.0 ~/twrp-10/device/realme/RMX2001
echo "" >> ~/twrp-10/device/realme/RMX2001/BoardConfig.mk
echo "TW_EXCLUDE_APEX := true" >> ~/twrp-10/device/realme/RMX2001/BoardConfig.mk
echo ""

echo "Starting Build"
cd ~/twrp-10
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch omni_RMX2001-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/twrp-10/out/target/product/*
version=$(cat ~/twrp-10/bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
version=$(echo $version | cut -c1-5)

mv recovery.img TWRP-10-${version}-RMX2001-$(date "+%Y%m%d").img
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls TWRP*.img)
