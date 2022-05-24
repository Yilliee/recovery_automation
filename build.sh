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
./orangefox_sync.sh --debug --ssh 0 --path ~/fox-10 -b 10.0
cd ~/fox-10/vendor/recovery
git am /drone/src/0001-OrangeFox.sh-Use-bash-as-the-default-shell-if-bash-h.patch
git am /drone/src/0002-New-build-vars-FOX_DEBUG_BUILD_RAW_IMAGE-FOX_REPLACE.patch
cp /drone/src/AromaFM.zip ~/fox-10/vendor/recovery/FoxFiles/AromaFM/AromaFM.zip
echo ""

echo "Cloning trees"
git clone https://github.com/Yilliee/recovery_a51 -b fox_10.0 ~/fox-10/device/samsung/a51
cd ~/fox-10/device/samsung/a51/
wget https://github.com/topjohnwu/Magisk/releases/download/v24.3/Magisk-v24.3.apk
export FOX_USE_SPECIFIC_MAGISK_ZIP="$HOME/fox-10/device/samsung/a51/Magisk-v24.3.apk"
echo ""

echo "Starting Build"
cd ~/fox-10
export CURR_DEVICE=a51
export OF_MAINTAINER="Yillié"
. build/envsetup.sh
lunch omni_a51-eng
make recoveryimage
echo ""

echo "Uploading zip"
cd ~/fox-10/out/target/product/*
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls OrangeFox*.zip)
