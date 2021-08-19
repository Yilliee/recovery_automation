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

echo "Syncing SHRP-10 Sources"
mkdir ~/shrp-10
cd ~/shrp-10
repo init https://github.com/SHRP/platform_manifest_twrp_omni.git -b v3_10.0 --depth=1
repo sync -j $(nproc --all)
echo ""

echo "Cloning trees"
cd ~/shrp-10
git clone https://github.com/yilliee/recovery_a51 -b shrp-10 ~/shrp-10/device/samsung/a51
echo ""

echo "Starting Build"
cd ~/shrp-10
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_a51-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/shrp-10/out/target/product/*
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls SHRP*a51*.zip)
