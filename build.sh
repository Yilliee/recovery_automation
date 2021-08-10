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

echo "Syncing OFOX-11"
git clone https://gitlab.com/OrangeFox/sync.git ~/sync
cd ~/sync && ./orangefox_sync.sh --ssh 0 --path ~/fox-11 --branch 11.0 -d
echo ""

echo "Cloning trees"
cd ~/fox-11
git clone https://github.com/Yilliee/recovery_a51 -b twrp-11 ~/fox-11/device/samsung/a51 --depth=1 --single-branch
echo ""

echo "Starting Build"
cd ~/fox-11
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export NOT_ORANGEFOX=true
lunch twrp_a51-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/fox-11/out/target/product/*

curl -sL https://git.io/file-transfer | sh
mv recovery.img OrangeFox-NOTOFOX.img
./transfer wet $(ls OrangeFox*.img)
