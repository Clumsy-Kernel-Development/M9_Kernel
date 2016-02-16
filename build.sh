#!/bin/bash
date=$(date +%d-%m-%y)
# Working Directory
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Destination Directory
dest=~/Output/M9_Kernel
# Location to dtbToolCM
dtbTool=~/toolchains/dtbToolCM
# Configuration Name
config=msm8994_defconfig
#Set Path, cross compile and user
export PATH=~/toolchains/arm64/android-toolchain-eabi/bin:$PATH
export ARCH=arm64
export SUBARCH=arm
export CROSS_COMPILE=aarch64-linux-android-
export KBUILD_BUILD_USER=LeeDrOiD

# Remove last kernel output
rm -r $dest  > /dev/null


#Get Version Number
echo "Please enter version number: "
read version

#Ask user if they would like to clean
read -p "Would you like to clean (y/n)? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    make clean 
    make mrproper
    rm .config  > /dev/null
fi

#Set Local Version String to kernel configuration
rm .version > /dev/null
VER="_LeeDrOiD-Hima-V$version"
DATE_START=$(date +"%s")

# Make the configuration
make $config

str="CONFIG_LOCALVERSION=\"$VER\""
sed -i "45s/.*/$str/" .config
read -p "Would you like to see menu config (y/n)? " -n 1 -r
echo 
   
if [[ $REPLY =~ ^[Yy]$ ]]
then
    make menuconfig
fi 

# Make
make -j8

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo
if (( $(($DIFF / 60)) == 0 )); then
echo " Build completed in $(($DIFF % 60)) seconds."
elif (( $(($DIFF / 60)) == 1 )); then
echo " Build completed in $(($DIFF / 60)) minute and $(($DIFF % 60)) seconds."
else
echo " Build completed in $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds."
fi
echo " Finish time: $(date +"%r")"
echo
mkdir -p $dest

# Make the dt.img 
echo "Making dt.img"
$dtbTool -2 -o arch/arm64/boot/dt.img -s 4096 -p scripts/dtc/ arch/arm64/boot/dts/ > /dev/null

# Get the modules
mkdir -p $dest/system/lib/modules/
find . -name '*ko' -exec cp '{}' $dest/system/lib/modules/ \;

# Copy Image and dt.img
cp arch/arm64/boot/Image $dest/.
cp arch/arm64/boot/dt.img $dest/.


echo "-> Done"

