#!/bin/bash

# --- Build Configuration ---

# 1. GApps Repository Details
GAPPS_URL="https://gitlab.com/axionaosp/vendor_gapps"
GAPPS_BRANCH="baklava"

# 2. LUNCH_TARGET and PRODUCT_NAME are set to the exact name your tree requires.
LUNCH_TARGET=lineage_renoir 

# Define the paths for clarity
DEVICE_PATH="device/xiaomi/renoir"
# TARGETING THE PRODUCT MK FILE: lineage_renoir.mk
VANILLA_MK="$DEVICE_PATH/lineage_renoir.mk"
TEMP_GMS_MK="$DEVICE_PATH/temp_gms.mk"


# --- GMS Core Configuration (Stored as a string in the script) ---
GMS_CONFIG=$(cat <<EOF
# Inherit from renoir device
\$(call inherit-product, device/xiaomi/renoir/device.mk)

# Inherit the common LineageOS product config (AS REQUIRED BY YOUR BUILD SETUP)
\$(call inherit-product, vendor/lineage/config/common.mk) 

-include vendor/lineage-priv/keys/keys.mk

# Gms CORE Flags
WITH_GMS := true
TARGET_CORE_GMS := true
TARGET_CORE_GMS_EXTRAS := false

# FINAL FIX: Bypassing the main.mk conflict by pointing to the standard package list.
\$(call inherit-product-if-exists, vendor/gapps/build/gapps-packages.mk)

PRODUCT_BRAND := Xiaomi
PRODUCT_DEVICE := renoir
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := M2101K9R
# PRODUCT_NAME must be lineage_renoir for the lunch command to succeed.
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

# 1. CLONE GAPPS REPO IF IT DOES'T EXIST
if [ ! -d "vendor/gapps" ]; then
    echo "GApps vendor directory not found. Cloning vendor/gapps..."
    git clone "$GAPPS_URL" vendor/gapps -b "$GAPPS_BRANCH"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to clone vendor/gapps. Check the URL and run manually: git clone $GAPPS_URL vendor/gapps -b $GAPPS_BRANCH"
        exit 1
    fi
    # FIX FOR RACE CONDITION: Wait a few seconds to let the filesystem stabilize
    echo "Cloning complete. Waiting 5 seconds to prevent race condition..."
    sleep 5
else
    echo "GApps vendor directory already exists. Skipping clone."
fi

echo "Setting up build environment..."
source build/envsetup.sh

# 2. CRITICAL FIX: Re-source envsetup.sh to register new vendor files.
echo "Re-sourcing envsetup.sh to register new vendor files."
source build/envsetup.sh

# 3. WRITE TEMPORARY GMS FILE
echo "$GMS_CONFIG" > "$TEMP_GMS_MK"

# 4. TEMPORARILY REPLACE THE VANILLA MK WITH THE GMS MK
echo "Swapping $VANILLA_MK with temporary GMS configuration."
# Check if the intended product file exists before moving it
if [ -f "$VANILLA_MK" ]; then
    mv "$VANILLA_MK" "$VANILLA_MK.vanilla_backup"
    mv "$TEMP_GMS_MK" "$VANILLA_MK"
else
    echo "ERROR: The main product file $VANILLA_MK was not found. Please verify the filename and try again."
    exit 1
fi

# 5. CLEANUP AND LUNCH
echo "Running make installclean..."
make installclean

echo "Lunching target: $LUNCH_TARGET (GMS Core Enabled)"
lunch "$LUNCH_TARGET"

# 6. PAUSE AND INSTRUCTIONS
echo "=========================================================="
echo "✅ BUILD SETUP COMPLETE. GMS CORE CONFIGURATION IS NOW ACTIVE."
echo "=========================================================="
echo "To start the build, run this command manually:"
echo ""
echo "    make -j\$(nproc --all)"
echo ""
echo "To clean up and restore your Vanilla configuration, run this command:"
echo ""
echo "    mv \"$VANILLA_MK.vanilla_backup\" \"$VANILLA_MK\" 2>/dev/null"
echo "=========================================================="
