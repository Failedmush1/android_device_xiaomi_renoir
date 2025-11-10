#!/bin/bash
#
# GApps Integration Script for Xiaomi renoir
# Uses AxionAOSP/vendor_gapps repository with specific configuration for 'core' GApps variant.

# --- Configuration Variables ---
DEVICE_CODENAME="renoir"
MANUFACTURER="xiaomi"
GA_REMOTE="AxionAOSP"
GA_FETCH_URL="https://gitlab.com/axionaosp/"
GA_PROJECT_NAME="vendor_gapps"
GA_BRANCH="baklava" # Updated to 'baklava' as requested

# --- Calculated Paths ---
GMS_DIR="vendor/gms"
CONFIG_FILE="device/${MANUFACTURER}/${DEVICE_CODENAME}/device.mk"
GMS_NAMESPACE="vendor/gms"

# --- Construct the final Git URL ---
GMS_REPO_URL="${GA_FETCH_URL}${GA_PROJECT_NAME}.git"

echo "==============================================="
echo "Starting GMS Integration Setup (AxionAOSP/vendor_gapps)"
echo "Target Config File: ${CONFIG_FILE}"
echo "GMS Repository: ${GMS_REPO_URL} (Branch: ${GA_BRANCH})"
echo "==============================================="

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file ${CONFIG_FILE} not found. Aborting."
    exit 1
fi

# 1. Clone/Sync GMS vendor sources
echo "1. Preparing GMS vendor sources in ${GMS_DIR}..."

if [ -d "$GMS_DIR" ]; then
    echo "Directory ${GMS_DIR} exists. Removing it to clone the new source."
    rm -rf "$GMS_DIR"
fi

echo "Performing 'git clone' from ${GMS_REPO_URL}..."
git clone --depth=1 -b "$GA_BRANCH" "$GMS_REPO_URL" "$GMS_DIR"

if [ $? -eq 0 ]; then
    echo "Successfully cloned ${GA_PROJECT_NAME}."
else
    echo "ERROR: Git clone failed. Check the URL and branch name (${GA_BRANCH})."
    exit 1
fi
echo ""

# 2. Inject vendor/gms into PRODUCT_SOONG_NAMESPACES and set GMS TYPE
echo "2. Injecting 'vendor/gms' namespace and setting GMS variant to 'core'..."

# Remove old namespace and variant settings if they exist to prevent duplicates
sed -i '/PRODUCT_SOONG_NAMESPACES.*vendor\/gms/d' "$CONFIG_FILE"
sed -i '/GAPPS_TYPE/d' "$CONFIG_FILE"


if ! grep -q "PRODUCT_SOONG_NAMESPACES" "$CONFIG_FILE"; then
    echo "PRODUCT_SOONG_NAMESPACES not found. Please verify ${CONFIG_FILE} contents."
fi

# Append new lines to the configuration file
echo "
# --- BEGIN AUTO-INJECTED GMS CONFIG (AxionAOSP Core) ---
# Set GMS variant to 'core' as requested
GAPPS_TYPE := core
# Add GMS namespace
PRODUCT_SOONG_NAMESPACES += \\
    ${GMS_NAMESPACE} \\

# --- END AUTO-INJECTED GMS CONFIG ---
" >> "$CONFIG_FILE"
echo "Successfully set GAPPS_TYPE to 'core' and injected ${GMS_NAMESPACE} into ${CONFIG_FILE}."
echo ""


# 3. Automatically add Pixel Launcher exclusion (NexusLauncher / Quickstep)
echo "3. Auto-excluding Pixel Launcher (NexusLauncher/Quickstep)..."

if grep -q "PRODUCT_PACKAGE_EXCLUDE_LIST.*NexusLauncher" "$CONFIG_FILE"; then
    echo "Exclusion list already found in ${CONFIG_FILE}. Skipping injection."
else
    echo "
# --- BEGIN AUTO-INJECTED PIXEL LAUNCHER EXCLUSION ---
PRODUCT_PACKAGE_EXCLUDE_LIST += \\
    NexusLauncher \\
    Quickstep \\
# --- END AUTO-INJECTED PIXEL LAUNCHER EXCLUSION ---
" >> "$CONFIG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Successfully added NexusLauncher and Quickstep to the exclusion list."
    else
        echo "ERROR: Failed to append exclusion list to ${CONFIG_FILE}."
        exit 1
    fi
fi
echo ""

# 4. Auto-excluding conflicting GMS configuration files (contextual_search.xml, etc.)
echo "4. Auto-excluding common conflicting XML files..."

if grep -q "PRODUCT_PACKAGE_EXCLUDE_FILES" "$CONFIG_FILE"; then
    echo "File exclusion list already found. Skipping injection."
else
    echo "
# --- BEGIN AUTO-INJECTED GMS CONFLICT FIXES ---
# Fixes 'overriding commands' build errors by excluding duplicate config files.
PRODUCT_PACKAGE_EXCLUDE_FILES += \\
    contextual_search.xml \\
    google-hiddenapi-package-allowlist.xml \\
    default_permissions_google.xml \\
# --- END AUTO-INJECTED GMS CONFLICT FIXES ---
" >> "$CONFIG_FILE"

    if [ $? -eq 0 ]; then
        echo "Successfully added exclusion for common conflict XML files."
    else
        echo "ERROR: Failed to append file exclusion list to ${CONFIG_FILE}."
        exit 1
    fi
fi
echo ""

# 5. Final instruction
echo "==============================================="
echo "GMS Setup Complete. Configuration updated."
echo "==============================================="
echo "!!! KEY CHECK REQUIRED !!!"
echo "You MUST ensure your private signing keys are in vendor/lineage-priv/keys/ or the build will fail immediately on the signing step."
echo ""
echo "NEXT STEPS:"
echo "   export WITH_GMS=true"
echo "   make clean"
echo "   brunch renoir user"
