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

echo "Syncing SHRP-11 Sources"
mkdir ~/pbrp-11 && cd ~/pbrp-11
repo init -u git://github.com/PitchBlackRecoveryProject/manifest_pb -b android-11.0
repo sync --force-sync -j 20
echo ""

echo "Cloning trees"
cd ~/pbrp-11
git clone https://github.com/Yilliee/recovery_a51 -b pbrp-11 ~/pbrp-11/device/samsung/a51 --depth=1 --single-branch
echo ""

echo "Starting Build"
cd ~/pbrp-11
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_a51-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/pbrp-11/out/target/product/*

curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls recovery.img)
