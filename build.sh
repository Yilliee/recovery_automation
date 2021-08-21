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

echo "Syncing Ofox"
git clone https://gitlab.com/orangefox/sync.git ; cd sync
./get_fox_10.sh ~/fox
cd ~/fox/vendor/recovery
git fetch https://gitlab.com/yillie/vendor_recovery fox_10.0
git cherry-pick 8212a5516cf9dece1f93cb3cafb6bcd69d261f7e
git cherry-pick a5dee11a78e30787e1490c65ba7d49f0fbc0b791
cd ~/fox/bootable/recovery
git fetch https://github.com/Yilliee/fox_bootable_recovery 10.0_2
git cherry-pick b2a046cefabf42c3a201622cc6560d138e0fbb32
echo ""

echo "Cloning trees"
cd ~/fox
git clone https://gitlab.com/orangefox/device/a51nsxx ~/fox/device/samsung/a51
echo "" >> ~/fox/device/samsung/a51/BoardConfig.mk
echo "# Don't Include Apex in recovery image" >> ~/fox/device/samsung/a51/BoardConfig.mk
echo "TW_EXCLUDE_APEX := true" >> ~/fox/device/samsung/a51/BoardConfig.mk
echo ""

echo "Starting Build"
cd ~/fox
. build/envsetup.sh
export OF_MAINTAINER="Yillié"
unset FOX_DYNAMIC_SAMSUNG_FIX
export FOX_CUSTOM_BINS_TO_INTERNAL="copy"
export FOX_USE_SED_BINARY=1
export FOX_USE_TAR_BINARY=1
export FOX_USE_GREP_BINARY=1
export FOX_USE_XZ_UTILS=1
export FOX_USE_NANO_EDITOR=1
export FOX_REPLACE_BUSYBOX_PS=1
export FOX_REPLACE_TOOLBOX_GETPROP=1
export FOX_USE_BASH_SHELL=1
export FOX_VERSION=R11.1_2-testing
export FOX_VARIANT=A12
export FOX_ASH_IS_BASH=1
export OF_STATUS_H="88"
lunch omni_a51-eng
make recoveryimage
echo ""

echo "Uploading zip"
cd ~/fox/out/target/product/*
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls OrangeFox*.zip)
