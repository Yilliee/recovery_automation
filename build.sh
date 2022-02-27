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

echo "Syncing Fox-11"
mkdir ~/fox-11
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 11.0 --path ~/fox-11
echo ""
cd ~/fox-11/vendor/recovery
wget https://github.com/Yilliee/fox_vendor_recovery/commit/3d34e0bde8959bad4eb53d41c5dca3bc9523a41a.patch
git am < 3d34e0bde8959bad4eb53d41c5dca3bc9523a41a.patch

echo "Cloning trees"
cd ~/fox-11
git clone https://github.com/Yilliee/recovery_RMX2001 -b fox_11.0 ~/fox-11/device/realme/wasabi
echo ""

echo "Starting Build"
cd ~/fox-11
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_wasabi-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/fox-11/out/target/product/*
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls OrangeFox*.zip)
