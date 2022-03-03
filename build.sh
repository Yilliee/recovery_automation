#!/bin/bash
echo ""
echo "Executing Build Script"
echo ""
# Set Time zone for Tz-Data
export TZ=Asia/Karachi
export CIRRUS_WORKING_DIR="/drone/src"
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

bash $CIRRUS_WORKING_DIR/test.sh
bash $CIRRUS_WORKING_DIR/build_rom.sh

