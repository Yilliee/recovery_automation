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
cd ~/shrp-10/bootable/recovery
git fetch https://github.com/Yilliee/fox_bootable_recovery.git 10.0_2
git cherry-pick b2a046cefabf42c3a201622cc6560d138e0fbb32
echo ""

echo "Cloning trees"
cd ~/shrp-10
git clone https://github.com/yilliee/recovery_exynos9611 -b shrp-10 ~/shrp-10/device/samsung/exynos9611
echo "" >> ~/shrp-10/device/samsung/exynos9611/BoardConfig.mk
echo "# Exclude Apex from recovery" >> ~/shrp-10/device/samsung/exynos9611/BoardConfig.mk
echo "# This should prevent the recovery from getting" >> ~/shrp-10/device/samsung/exynos9611/BoardConfig.mk
echo "# Stuck at splash in beta GSIs" >> ~/shrp-10/device/samsung/exynos9611/BoardConfig.mk
echo "TW_EXCLUDE_APEX := true" >> ~/shrp-10/device/samsung/exynos9611/BoardConfig.mk
echo ""

echo "Starting Build"
cd ~/shrp-10
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL="C"
lunch omni_exynos9611-eng
make recoveryimage
echo ""

echo "Uploading recovery image"
cd ~/shrp-10/out/target/product/*

curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls SHRP*9611*.zip)
