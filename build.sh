#!/bin/bash

# Just a basic script U can improvise lateron asper ur need xD 

MANIFEST="https://github.com/PitchBlackRecoveryProject/manifest_pb -b android-11.0"

DT_PATH=device/xiaomi/camellia
DT_LINK="https://github.com/willzyx-hub/pbrp_device_xiaomi_camellia -b android-11.0"

echo " ===+++ Setting up Build Environment +++==="
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
mkdir ~/pbrp && cd ~/pbrp
DEVICE=${DT_PATH##*\/}

echo " ===+++ Syncing Recovery Sources +++==="
repo init -u $MANIFEST
repo sync
git clone $DT_LINK $DT_PATH

echo " ===+++ Building Recovery +++==="

. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch omni_${DEVICE}-eng && mka bootimage
ls

cd $OUT/recovery/root
./ldcheck -p system/lib64:vendor/lib64 -d system/bin/qseecomd
cd -

# Upload zips & boot.img (U can improvise lateron adding telegram support etc etc)
echo " ===+++ Uploading Recovery +++==="
version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip
cd out/target/product/$DEVICE
mv boot.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img

#curl -T $OUTFILE https://oshi.at
curl -sL $OUTFILE https://git.io/file-transfer | sh
./transfer wet *.zip
