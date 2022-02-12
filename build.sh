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
#cd ~/twrp-11/bootable/recovery
#wget https://transfer.sh/b5yB7E/0001-1-2-Introduce-TW_CPU_POS_X-and-TW_TIME_POS_X.patch
#git am 0001-1-2-Introduce-TW_CPU_POS_X-and-TW_TIME_POS_X.patch
#cd ~/twrp-11/vendor/twrp
#wget https://transfer.sh/uqutV0/0001-2-2-makevars-Introduce-TW_CPU_POS_X-and-TW_TIME_POS_.patch
#git am 0001-2-2-makevars-Introduce-TW_CPU_POS_X-and-TW_TIME_POS_.patch
cp /drone/src/ui.xml ~/twrp-11/bootable/recovery/gui/theme/portrait_hdpi/ui.xml || exit 1
echo ""

echo "Cloning trees"
cd ~/twrp-11
git clone https://github.com/Yilliee/recovery_a51 -b twrp-11 ~/twrp-11/device/samsung/a51 --depth=1 --single-branch
git clone https://github.com/Yilliee/recovery_universal9611-common -b twrp-11 ~/twrp-11/device/samsung/universal9611-common --depth=1 --single-branch
git clone https://github.com/Yilliee/android_kernel_samsung_exynos9611 -b Celicia ~/twrp-11/kernel/samsung/universal9610 --depth=1 --single-branch
#echo "TW_CPU_POS_X := 590" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
#echo "TW_TIME_POS_X := 120" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
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
