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

echo "Syncing TWRP-11"
mkdir ~/twrp-11
cd ~/twrp-11
repo init https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11 --depth=1
repo sync -j 20
rm -rf ~/twrp-11/bootable/recovery
git clone https://github.com/TeamWin/android_bootable_recovery -b android-11 ~/twrp-11/bootable/recovery
cd ~/twrp-11/bootable/recovery
git reset --hard 2485980a9a4adc6edf9e68a7f246052428be7453
###############################
#wget https://transfer.sh/i1RmUr/0001-sdcard-only-bind-mount-sdcard-after-successful-prepa.patch
#git am 0001-sdcard-only-bind-mount-sdcard-after-successful-prepa.patch
###############################
#wget http://transfer.sh/DFCAtE/0001-Add-an-option-to-specify-a-custom-x-axis-value-for-s.patch
#wget http://transfer.sh/KDxMIa/0002-Allow-to-specify-the-status-bar-left-and-right-paddi.patch
#git am < 0001-Add-an-option-to-specify-a-custom-x-axis-value-for-s.patch
#git am < /0002-Allow-to-specify-the-status-bar-left-and-right-paddi.patch
#cd ~/twrp-11/bootable/recovery/gui/theme/portrait_hdpi
#rm ui.xml
#rm splash.xml
#wget http://transfer.sh/sb5bz7/ui.xml
#wget http://transfer.sh/88FU5c/splash.xml
###############################
echo ""

echo "Cloning trees"
cd ~/twrp-11
git clone https://github.com/Yilliee/recovery_a51 -b twrp-11 ~/twrp-11/device/samsung/a51 --depth=1 --single-branch
###############################
#echo "TW_CLOCK_POS_X := 350" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
#echo "TW_STATUSBAR_PADDING_LEFT := 50" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
#echo "TW_STATUSBAR_PADDING_RIGHT := 950" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
###############################
echo ""

echo "Starting Build"
cd ~/twrp-11
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_a51-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/twrp-11/out/target/product/*
version=$(cat ~/twrp-11/bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
version=$(echo $version | cut -c1-5)

mv recovery.img TWRP-11-${version}-a51-$(TZ='Asia/Karachi' date "+%Y%m%d-%H%M").img
curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls TWRP*.img)
