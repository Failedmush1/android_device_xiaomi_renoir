#!/bin/bash

DEVICE_CODENAME="renoir"
MANUFACTURER="xiaomi"
BUILD_TARGET="lineage_${DEVICE_CODENAME}-user"
GA_REVISION="bka" 
GA_REMOTE="EvolutionX"
GA_FETCH_URL="https://git.evolution-x.org/Evolution-X/"
GA_PROJECT_NAME="vendor_gms"
DEVICE_DIR="device/${MANUFACTURER}/${DEVICE_CODENAME}"
DEVICE_MK="${DEVICE_DIR}/device.mk"
BOARD_CONFIG_MK="${DEVICE_DIR}/BoardConfig.mk"
PRODUCT_MK="${DEVICE_DIR}/lineage_${DEVICE_CODENAME}.mk" 
GMS_MAKEFILE="vendor/gms/gms_pico.mk" 

check_error() {
    if [ $? -ne 0 ]; then
        echo "❌ ERROR: $1"
        exit 1
    fi
}

rm -f .repo/local_manifests/gapps.xml

mkdir -p .repo/local_manifests
cat > .repo/local_manifests/gapps.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="${GA_REMOTE}" fetch="${GA_FETCH_URL}" />
  <project path="vendor/gms" name="${GA_PROJECT_NAME}" remote="${GA_REMOTE}" revision="${GA_REVISION}" />
</manifest>
EOF
check_error "Failed to create gapps.xml manifest."

if [ -f "$DEVICE_MK" ]; then
    sed -i '/vendor\/gapps\/arm64\/arm64-vendor.mk/d' "$DEVICE_MK"
    sed -i '/vendor\/gms\//d' "$DEVICE_MK"
    
    if ! grep -q "$GMS_MAKEFILE" "$DEVICE_MK"; then
        echo "" >> "$DEVICE_MK"
        echo "include $GMS_MAKEFILE" >> "$DEVICE_MK"
    fi
fi

if [ -f "$BOARD_CONFIG_MK" ]; then
    if ! grep -q "BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES" "$BOARD_CONFIG_MK"; then
        echo "" >> "$BOARD_CONFIG_MK"
        echo "BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true" >> "$BOARD_CONFIG_MK"
    fi
    if ! grep -q "BUILD_BROKEN_DUP_RULES" "$BOARD_CONFIG_MK"; then
        echo "BUILD_BROKEN_DUP_RULES := true" >> "$BOARD_CONFIG_MK"
    fi
fi

# Source environment must run before any build commands
source build/envsetup.sh
check_error "Failed to source build/envsetup.sh."

make clean
check_error "Failed to clean build artifacts."

# CHANGE APPLIED HERE: Using direct string "renoir"
brunch renoir user
check_error "Build failed."
