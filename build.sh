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

echo "Syncing TWRP-12"
mkdir ~/twrp-12
cd ~/twrp-12
repo init https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1 --depth=1
repo sync -j 20
cd ~/twrp-12/external/icu || exit 2
git revert d2bbca5138c7083345bc3c3c0a8d47332188f66d || exit 2
#cp /drone/src/ui.xml ~/twrp-11/bootable/recovery/gui/theme/portrait_hdpi/ui.xml || exit 1
echo ""

echo "Cloning trees"
cd ~/twrp-12
git clone https://github.com/Yilliee/recovery_a51 -b twrp-11 ~/twrp-12/device/samsung/a51 --depth=1 --single-branch
git clone https://github.com/Yilliee/recovery_universal9611-common -b twrp-11 ~/twrp-12/device/samsung/universal9611-common --depth=1 --single-branch
echo -e "\nTARGET_SUPPORTS_64_BIT_APPS := true" >> ~/twrp-12/device/samsung/universal9611-common/BoardConfigCommon.mk
echo ""

echo "Starting Build"
cd ~/twrp-12
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_a51-eng
make recoveryimage -j$( nproc --all )
echo ""

echo "Uploading recovery image"
cd ~/twrp-12/out/target/product/*
version=$(cat ~/twrp-12/bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
version=$(echo $version | cut -c1-5)

mv recovery.img TWRP-12-${version}-a51-$(TZ='Asia/Karachi' date "+%Y%m%d-%H%M").img
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls TWRP*.img)
