#!/bin/bash

# --- Build Configuration ---

# 1. GApps Repository Details (MindTheGapps)
GAPPS_URL="https://gitlab.com/MindTheGapps/vendor_gapps"
GAPPS_BRANCH="baklava"

# 2. LUNCH_TARGET and PRODUCT_NAME are set to the exact name your tree requires.
LUNCH_TARGET=lineage_renoir 
DEVICE_PATH="device/xiaomi/renoir"
VANILLA_MK="$DEVICE_PATH/lineage_renoir.mk"
TEMP_GMS_MK="$DEVICE_PATH/temp_gms.mk"


# --- GMS Core Configuration (Minimalist Approach) ---
GMS_CONFIG=$(cat <<EOF
# Inherit from renoir device
\$(call inherit-product, device/xiaomi/renoir/device.mk)

# Inherit the common LineageOS product config (AS REQUIRED BY YOUR BUILD SETUP)
\$(call inherit-product, vendor/lineage/config/common.mk) 

-include vendor/lineage-priv/keys/keys.mk

# FINAL FIX: Only include the GApps product file.
\$(call inherit-product-if-exists, vendor/gapps/product/gapps.mk)

PRODUCT_BRAND := Xiaomi
PRODUCT_DEVICE := renoir
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := M2101K9R
PRODUCT_NAME := lineage_renoir

PRODUCT_BUILD_PROP_OVERRIDES += \\
    BuildDesc="renoir_global-user 13 TKQ1.220829.002 V14.0.7.0.TKIMIXM release-keys" \\
    BuildFingerprint=Xiaomi/renoir_global/renoir:13/TKQ1.220829.002/V14.0.7.0.TKIMIXM:user/release-keys \\
    DeviceProduct=renoir \\
    SystemName=renoir_global

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
EOF
)

# --- Setup Execution ---

# 1. CLONE GAPPS REPO (Safeguard in case it was deleted)
if [ ! -d "vendor/gapps" ]; then
    echo "GApps vendor directory not found. Cloning MindTheGapps..."
    git clone "$GAPPS_URL" vendor/gapps -b "$GAPPS_BRANCH"
fi

echo "Setting up build environment..."
source build/envsetup.sh

# 2. CRITICAL CHANGE: LUNCH FIRST (before GApps swap) to avoid the 'trunk_staging' crash.
echo "Lunching target: $LUNCH_TARGET (Initial environment setup)"
lunch "$LUNCH_TARGET"

# 3. WRITE TEMPORARY GMS FILE
echo "$GMS_CONFIG" > "$TEMP_GMS_MK"

# 4. TEMPORARILY REPLACE THE VANILLA MK WITH THE GMS MK
echo "Swapping $VANILLA_MK with temporary GMS configuration."
if [ -f "$VANILLA_MK" ]; then
    mv "$VANILLA_MK" "$VANILLA_MK.vanilla_backup"
    mv "$TEMP_GMS_MK" "$VANILLA_MK"
else
    echo "ERROR: The main product file $VANILLA_MK was not found. Please verify the filename and try again."
    exit 1
fi

# 5. INSTRUCTIONS
echo "=========================================================="
echo "✅ BUILD SETUP COMPLETE."
echo "=========================================================="
echo "The build environment is now loaded, and the GApps configuration is active."
echo "To start the build, run this command manually:"
echo ""
echo "    make -j\$(nproc --all)"
echo ""
echo "To clean up and restore your Vanilla configuration, run this command:"
echo ""
echo "    mv \"$VANILLA_MK.vanilla_backup\" \"$VANILLA_MK\" 2>/dev/null"
echo "=========================================================="
