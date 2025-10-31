#!/bin/bash

# --- Build Configuration ---

# 1. GApps Repository Details (MindTheGapps)
GAPPS_URL="https://gitlab.com/MindTheGapps/vendor_gapps"
GAPPS_BRANCH="baklava"

# 2. PRODUCT_NAME for the build.
PRODUCT_NAME=lineage_renoir 
DEVICE_PATH="device/xiaomi/renoir"
VANILLA_MK="$DEVICE_PATH/lineage_renoir.mk"
TEMP_GMS_MK="/tmp/temp_gms.mk"


# --- GMS Core Configuration (Minimalist Approach - MindTheGapps) ---
GMS_CONFIG=$(cat <<EOF
# Inherit from renoir device
\$(call inherit-product, device/xiaomi/renoir/device.mk)

# Inherit the common LineageOS product config
\$(call inherit-product, vendor/lineage/config/common.mk)

-include vendor/lineage-priv/keys/keys.mk

# GMS Flags for Core Integration (Necessary to trigger GMS inclusion)
WITH_GMS := true
TARGET_CORE_GMS := true
TARGET_CORE_GMS_EXTRAS := false

# CRITICAL FINAL FIX: Using the verified architecture-specific MindTheGapps path
\$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)

PRODUCT_SOONG_NAMESPACES += vendor/gapps

# Core Product Identity Definitions (Required by the build system)
PRODUCT_BRAND := Xiaomi
PRODUCT_DEVICE := renoir
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := M2101K9R
PRODUCT_NAME := lineage_renoir

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
EOF
)

# --- Setup Execution ---

# 1. CLEANUP PREVIOUS RUN (Ensures a clean state)
echo "--- Performing Critical Cleanup ---"
mv "$VANILLA_MK.vanilla_backup" "$VANILLA_MK" 2>/dev/null
make clean

# 2. CLONE GAPPS REPO (Safeguard in case it was deleted)
if [! -d "vendor/gapps" ]; then
    echo "GApps vendor directory not found. Cloning MindTheGapps..."
    git clone "$GAPPS_URL" vendor/gapps -b "$GAPPS_BRANCH"
fi

echo "Setting up build environment..."
source build/envsetup.sh

# 3. CRITICAL FIX: MANUALLY EXPORTING VARIABLES TO SKIP THE CRASHING 'LUNCH' COMMAND
echo "Manually exporting build variables (Skipping 'lunch' to avoid Soong crash)..."
export TARGET_PRODUCT="$PRODUCT_NAME"
export TARGET_BUILD_VARIANT="user"

# 4. WRITE TEMPORARY GMS FILE
echo "$GMS_CONFIG" > "$TEMP_GMS_MK"

# 5. TEMPORARILY REPLACE THE VANILLA MK WITH THE GMS MK
echo "Swapping $VANILLA_MK with temporary GMS configuration."
if [ -f "$VANILLA_MK" ]; then
    mv "$VANILLA_MK" "$VANILLA_MK.vanilla_backup"
    mv "$TEMP_GMS_MK" "$VANILLA_MK"
else
    echo "ERROR: The main product file $VANILLA_MK was not found. Please verify the filename and try again."
    exit 1
fi

# 6. START BUILD
echo "=========================================================="
echo "✅ ENVIRONMENT SETUP COMPLETE. STARTING FINAL BUILD."
echo "=========================================================="

make -j$(nproc --all)

# 7. CLEANUP AFTER BUILD (CRITICAL)
echo "=========================================================="
echo "BUILD FINISHED. RESTORING VANILLA CONFIGURATION."
echo "=========================================================="

mv "$VANILLA_MK.vanilla_backup" "$VANILLA_MK" 2>/dev/null

echo "Cleanup complete. Source tree is ready for the next build."
