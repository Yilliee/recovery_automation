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
git fetch https://github.com/yilliee/fox_vendor_recovery fox_10.0
git cherry-pick 55050eb9c14ea9be2b5e0621a7e3485b5c755109
echo ""

echo "Cloning trees"
git clone https://github.com/Yilliee/recovery_a51 -b fox_10.0 ~/fox-10/device/samsung/a51
echo ""

echo "Starting Build"
cd ~/fox-10
. build/envsetup.sh
lunch omni_a51-eng
export oF_MAINTAINER="Yillié"
make recoveryimage
echo ""

echo "Uploading zip"
cd ~/fox-10/out/target/product/*
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls OrangeFox*.zip)
