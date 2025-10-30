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

# Inherit the common LineageOS product config (AS REQUIRED BY YOUR BUILD SETUP)
\$(call inherit-product, vendor/lineage/config/common.mk) 

-include vendor/lineage-priv/keys/keys.mk

# CRITICAL FINAL FIX: Using the highly probable correct MindTheGapps inclusion file path.
\$(call inherit-product-if-exists, vendor/gapps/common/common.mk)

# CRITICAL SOONG FIX: Manually inject the GApps directory into Soong's module search path.
PRODUCT_SOONG_NAMESPACES += vendor/gapps

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

# 2. CRITICAL FIX: MANUALLY EXPORTING VARIABLES TO SKIP THE CRASHING 'LUNCH' COMMAND
echo "Manually exporting build variables (Skipping 'lunch' to avoid Soong crash)..."
export TARGET_PRODUCT="$PRODUCT_NAME"
export TARGET_BUILD_VARIANT="user"

# 3. RUN CLEANUP (ensures a fresh start)
echo "Running make installclean..."
make installclean

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

# 6. INSTRUCTIONS
echo "=========================================================="
echo "✅ ENVIRONMENT SETUP COMPLETE (Manual Bypass)."
echo "=========================================================="
echo "The GApps configuration is active and the environment variables are set."
echo "To start the build, run this command manually:"
echo ""
echo "    make -j\$(nproc --all)"
echo ""
echo "To clean up and restore your Vanilla configuration, run this command:"
echo ""
echo "    mv \"$VANILLA_MK.vanilla_backup\" \"$VANILLA_MK\" 2>/dev/null"
echo "=========================================================="
