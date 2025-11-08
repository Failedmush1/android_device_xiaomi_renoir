#!/bin/bash
#
# GApps Integration Script for Xiaomi renoir (sm8350 platform)
# This script prepares the build environment for GApps inclusion by:
# 1. Cloning or syncing the GMS vendor sources (from EvolutionX) into vendor/gms.
# 2. Injecting 'vendor/gms' into the PRODUCT_SOONG_NAMESPACES list in device.mk.

# --- Configuration Variables from User Input ---
DEVICE_CODENAME="renoir"
MANUFACTURER="xiaomi"
GA_REMOTE="EvolutionX"
GA_FETCH_URL="https://git.evolution-x.org/Evolution-X/"
GA_PROJECT_NAME="vendor_gms"

# --- Calculated Paths ---
GMS_DIR="vendor/gms"
CONFIG_FILE="device/${MANUFACTURER}/${DEVICE_CODENAME}/device.mk"
GMS_NAMESPACE="vendor/gms"

# --- Construct the final Git URL ---
GMS_REPO_URL="${GA_FETCH_URL}${GA_PROJECT_NAME}"

echo "==============================================="
echo "Starting GMS Integration Setup"
echo "Target Config File: ${CONFIG_FILE}"
echo "GMS Repository: ${GMS_REPO_URL}"
echo "==============================================="

# 1. Clone/Sync GMS vendor sources
echo "1. Preparing GMS vendor sources in ${GMS_DIR}..."

if [ -d "$GMS_DIR" ]; then
    echo "Directory ${GMS_DIR} exists. Attempting 'repo sync' for updates..."
    
    # Run repo sync only on this directory. This is the standard way to update.
    # We use -j$(nproc --all) for parallel syncing, matching the build environment practice.
    repo sync -j$(nproc --all) "$GMS_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Successfully synced GMS repository."
    else
        echo "WARNING: 'repo sync vendor/gms' failed."
        echo "If this directory was cloned manually (not via a local manifest), sync will fail."
    fi
else
    # If the directory doesn't exist, we perform a direct git clone for the initial setup.
    echo "Directory ${GMS_DIR} missing. Performing initial 'git clone' from ${GA_REMOTE}..."
    git clone --depth=1 "$GMS_REPO_URL" "$GMS_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Successfully performed initial clone."
    else
        echo "ERROR: Git clone failed. Check the URL and ensure the repository exists."
        exit 1
    fi
fi
echo ""

# 2. Inject vendor/gms into PRODUCT_SOONG_NAMESPACES in device.mk
echo "2. Injecting 'vendor/gms' into PRODUCT_SOONG_NAMESPACES..."

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file ${CONFIG_FILE} not found. Aborting namespace injection."
    exit 1
fi

# Check if vendor/gms is already present to prevent duplicates
if grep -q "vendor/gms" "$CONFIG_FILE"; then
    echo "Namespace 'vendor/gms' already found in ${CONFIG_FILE}. Skipping injection."
else
    # sed command to find the PRODUCT_SOONG_NAMESPACES += \ line and append the GMS path immediately after it.
    sed -i "/^PRODUCT_SOONG_NAMESPACES/ a\\	${GMS_NAMESPACE} \\\\" "$CONFIG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Successfully injected ${GMS_NAMESPACE} into ${CONFIG_FILE}."
    else
        echo "ERROR: sed command failed. Please check ${CONFIG_FILE} manually."
        exit 1
    fi
fi
echo ""

# 3. Final instruction
echo "==============================================="
echo "GMS Setup Complete. Configuration updated."
echo "==============================================="
echo "NEXT STEPS:"
echo "1. Export WITH_GMS=true."
echo "2. Clean and restart the build to apply the permanent configuration change."
echo ""
echo "   export WITH_GMS=true"
echo "   make clean"
echo "   brunch renoir user"
