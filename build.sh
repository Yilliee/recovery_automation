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
repo init -u https://github.com/PitchBlackRecoveryProject/manifest_pb -b android-11.0
repo sync --force-sync -j 20
cd ~/pbrp-11/bootable/recovery
git am /drone/src/0001-events-Change-preferences-for-haptics-vars.patch
echo ""

echo "Cloning trees"
cd ~/pbrp-11
git clone https://github.com/Yilliee/recovery_a51 -b twrp-11 device/samsung/a51
git clone https://github.com/Yilliee/recovery_universal9611-common -b pbrp-11 device/samsung/universal9611-common
echo ""

echo "Starting Build"
cd ~/pbrp-11
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_a51-eng
make recoveryimage
echo ""

echo ""
echo "Creating recovery zip the proper (but still not the proper) way"
echo ""
sed -i s@'$OUT'@'~/pbrp-11/out/target/product/a51'@g ~/pbrp-11/vendor/utils/pb_build.sh
sed -i s@'cd ${OUT}/../../../../'@'cd ~/pbrp-11'@g ~/pbrp-11/vendor/utils/pb_build.sh
sed -i s@'$TARGET_PRODUCT'@'twrp_a51'@g ~/pbrp-11/vendor/utils/pb_build.sh
sed -i s@'-$PBRP_BUILD_TYPE'@'-BETA'@g ~/pbrp-11/vendor/utils/pb_build.sh
bash ~/pbrp-11/vendor/utils/pb_build.sh

echo ""
echo "Uploading recovery image and zip"
echo ""

cd $OUT

PB_VERSION=$(cat ~/pbrp-11/bootable/recovery/variables.h | egrep "define\s+PB_MAIN_VERSION" | awk '{print $3}' | tr -d '"')
cp recovery.img PBRP-11-$PB_VERSION-a51-$(TZ=Asia/Karachi date +%Y%m%d-%H%M).img

curl -sL https://git.io/file-transfer | sh
./transfer wet $(ls PBRP*.img)
./transfer wet $(ls PBRP*.zip)

