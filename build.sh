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
cd ~/twrp-11/bootable/recovery
git fetch https://github.com/Yilliee/android_bootable_recovery android-11
git cherry-pick 16cbd6b7279e4350b6659dee4a5c3fd2636e68fc^..32263849621461ee8191b0617494de07e5e38740
cd ~/twrp-11/vendor/twrp
git am /drone/src/patches/vendor_twrp/* || exit 3
echo ""

echo "Cloning trees"
cd ~/twrp-11
git clone https://github.com/Yilliee/recovery_a51 -b twrp-11 ~/twrp-11/device/samsung/a51 --depth=1 --single-branch
git clone https://github.com/Yilliee/recovery_universal9611-common -b twrp-11 ~/twrp-11/device/samsung/universal9611-common --depth=1 --single-branch
#git clone https://github.com/Yilliee/android_kernel_samsung_exynos9611 -b Celicia ~/twrp-11/kernel/samsung/universal9610 --depth=1 --single-branch
echo "TW_CUSTOM_CLOCK_POS := \"right\"" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
echo "TW_CUSTOM_CPU_POS := left" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
echo "TW_CUSTOM_BATTERY_POS := \"center\"" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
echo "TW_STATUS_ICONS_ALIGN := 3" >> ~/twrp-11/device/samsung/a51/BoardConfig.mk
echo ""

for i in portrait_hdpi portrait_mdpi watch_mdpi landscape_hdpi landscape_mdpi ; do
	echo "Replacing theme with $i"
	sed -i 's/TW_THEME/#TW_THEME/g' ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
	sed -i 's/TW_ROTATION/#TW_ROTATION/g' ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
	sed -i 's/RECOVERY_TOUCHSCREEN_SWAP_XY/#RECOVERY_TOUCHSCREEN_SWAP_XY/g' ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
	sed -i 's/RECOVERY_TOUCHSCREEN_FLIP_X/#RECOVERY_TOUCHSCREEN_FLIP_X/g' ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
	echo "TW_THEME := $i" >> ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
	if [ "$i" == "landscape_hdpi" ] || [ "$i" == "landscape_mdpi" ]; then
		echo "TW_ROTATION := 270" >> ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
		echo "RECOVERY_TOUCHSCREEN_SWAP_XY := true" >> ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
		echo "RECOVERY_TOUCHSCREEN_FLIP_X := true" >> ~/twrp-11/device/samsung/universal9611-common/BoardConfigCommon.mk
	fi
	echo "Starting Build"
	cd ~/twrp-11
	. build/envsetup.sh
	export ALLOW_MISSING_DEPENDENCIES=true
	lunch twrp_a51-eng
	make recoveryimage -j$( nproc --all )
	echo ""

	echo "Uploading recovery image"
	cd ~/twrp-11/out/target/product/*
	version=$(cat ~/twrp-11/bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
	version=$(echo $version | cut -c1-5)

	mv recovery.img TWRP-11-${version}-a51-$(TZ='Asia/Karachi' date "+%Y%m%d-%H%M")-$i.img
	curl -sL https://git.io/file-transfer | sh
	./transfer wet $(ls TWRP*.img) >> $HOME/all
	echo ""
	echo ""
	cat $HOME/all
	echo ""
	echo ""
	cd ~/twrp-11
	make clean -j$( nproc --all )
	rm -rf ~/twrp-11/out
done
cd $HOME
curl -sL https://git.io/file-transfer | sh
./transfer wet $HOME/all
echo ""
echo ""
echo ""
cat $HOME/all
echo ""
echo ""
echo ""
