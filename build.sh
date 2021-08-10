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
git cherry-pick 76afae08593815f8053ce1d56a2f29856a7bda4c
echo ""
echo "Cloning trees"
cd ~/fox
git clone https://gitlab.com/orangefox/device/a51nsxx device/samsung/a51
echo ""
echo "Starting Build"
. build/envsetup.sh
export OF_MAINTAINER="Yillié"
lunch omni_a51-eng
make recoveryimage
echo ""
echo "Uploading zip"
cd ~/fox/out/target/product/*
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls OrangeFox*.zip)

