#!/bin/bash

# Get current directory
TOP=$(pwd)
RENOIR_PATCHES=$TOP/device/xiaomi/renoir/patches

# Function to apply patches
apply_patches() {
    local dir=$1
    local patch_dir=$2
    echo "Applying patches in $dir..."
    cd $TOP/$dir
    for patch in $patch_dir/*.patch; do
        git am "$patch" || { echo "Failed to apply $patch"; git am --abort; }
    done
}

# Apply frameworks/base patches
apply_patches "frameworks/base" "$RENOIR_PATCHES/frameworks_base"

# Apply packages/apps/Settings patches
apply_patches "packages/apps/Settings" "$RENOIR_PATCHES/packages_apps_Settings"

echo "All patches applied successfully."
