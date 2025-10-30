#!/bin/bash

# --- Build Configuration ---

# 1. GApps Repository Details (from your provided URL)
GAPPS_URL="https://gitlab.com/axionaosp/vendor_gapps"
GAPPS_BRANCH="baklava"

# 2. Fix the fatal lunch target syntax error.
# !!! CRITICAL: CHANGE THIS TO YOUR CRDROID TARGET (e.g., crDroid_renoir-user) !!!
LUNCH_TARGET=lineage_renoir-user

# Set the number of threads for the build (for the user's manual step)
THREADS=$(nproc --all)

# Define the paths for clarity
DEVICE_PATH="device/xiaomi/renoir"
VANILLA_MK="$DEVICE_PATH/lineage_renoir.mk"
TEMP_GMS_MK="$DEVICE_PATH/temp_gms.mk"


# --- GMS Core Configuration (Stored as a string in the script) ---

# This includes the GMS flags and the GApps vendor inheritance.
GMS_CONFIG=$(cat <<EOF
# Inherit from renoir device
\$(call inherit-product, device/xiaomi/renoir/device.mk)

# Inherit some common Lineage stuff. (NOTE: This path may need to be updated for crDroid!)
\$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

-include vendor/lineage-priv/keys/keys.mk

# Gms CORE Flags (ADDED BACK from gapps.txt)
WITH_GMS := true
TARGET_CORE_GMS := true
TARGET_CORE_GMS_EXTRAS := false

# CRITICAL FIX: This line activates the packages from the 'vendor/gapps' folder.
\$(call inherit-product, vendor/gapps/build/gapps-packages.mk)

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

# 1. CLONE GAPPS REPO IF IT DOESN'T EXIST
if [ ! -d "vendor/gapps" ]; then
    echo "GApps vendor directory not found. Cloning vendor/gapps..."
    git clone "$GAPPS_URL" vendor/gapps -b "$GAPPS_BRANCH"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to clone vendor/gapps. Check the URL and run manually: git clone $GAPPS_URL vendor/gapps -b $GAPPS_BRANCH"
        exit 1
    fi
else
    echo "GApps vendor directory already exists. Skipping clone."
fi


echo "Setting up build environment..."
source build/envsetup.sh

# 2. WRITE TEMPORARY GMS FILE
echo "$GMS_CONFIG" > "$TEMP_GMS_MK"

# 3. TEMPORARILY REPLACE THE VANILLA MK WITH THE GMS MK
echo "Swapping $VANILLA_MK with temporary GMS configuration."
mv "$VANILLA_MK" "$VANILLA_MK.vanilla_backup"
mv "$TEMP_GMS_MK" "$VANILLA_MK"

# 4. CLEANUP AND LUNCH
echo "Running make installclean..."
make installclean

echo "Lunching target: $LUNCH_TARGET (GMS Core Enabled)"
lunch "$LUNCH_TARGET"

# 5. PAUSE AND INSTRUCTIONS
echo "=========================================================="
echo "✅ BUILD SETUP COMPLETE. GMS CORE CONFIGURATION IS NOW ACTIVE."
echo "=========================================================="
echo "To start the build, run this command manually:"
echo ""
echo "    make -j$(nproc --all)"
echo ""
echo "To clean up and restore your Vanilla configuration, run this command:"
echo ""
echo "    mv \"$VANILLA_MK.vanilla_backup\" \"$VANILLA_MK\""
echo "=========================================================="
