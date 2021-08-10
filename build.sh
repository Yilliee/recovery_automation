#!/bin/bash
echo ""
echo "Executing Build Script"
echo ""
# Set Time zone for Tz-Data
export TZ=Asia/Karachi
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
echo ""
echo "Making sure the required dependencies are there"
echo ""
apt update
apt install -y git-core gnupg flex bison build-essential \
zip curl zlib1g-dev gcc-multilib g++-multilib \
libc6-dev-i386 libncurses5-dev lib32ncurses5-dev \
x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
libxml2-utils xsltproc unzip fontconfig openjdk-8-jdk \
python3
echo ""
echo "Make a symlink to utilize python3 as the default"
ln -s /usr/bin/python3 /usr/bin/python || exit 2
echo ""
echo "Installing the repo launcher"
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
echo "Configuring git"
git config --global user.name "Yillié"
git config --global user.email "yilliee@protonmail.com"
echo "Installed all the dependecies"
echo ""
echo ""

echo "Syncing Octavi OS"
mkdir Octavi && cd Octavi
repo init --depth=1 --no-repo-verify -u https://github.com/Octavi-OS/platform_manifest.git -b 12 -g default,-mips,-darwin,-notdefault
git clone https://github.com/Octavi-OS-GSI/treble_manifest.git --depth 1 -b 12 .repo/local_manifests
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8 || exit 2

cd device/phh/treble && bash generate.sh octavi && cd ../../../ || exit 3

# build rom
source build/envsetup.sh
lunch treble_arm64_bgN-userdebug
export TZ=Asia/Karachi # Put before last build command
make sepolicy
make bootimage
make init

#mka systemimage

# upload rom (if you don't need to upload multiple files, then you don't need to edit next line)
#rclone copy out/target/product/phhgsi_arm64_bgN/system.img cirrus:OctaviOS-GSI -P

