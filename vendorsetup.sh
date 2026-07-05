#!/bin/bash

# Color definitions (fix variable names)
color="\u001B[0;32m"
endcolor="\u001B[0m"

echo -e "${color}Setup Gapps${endcolor}"

if [[ "$WITH_GMS" == "true" ]]; then
    USER_INPUT="yes"
else
    USER_INPUT="no"
fi

if [[ "$USER_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Gapps support enabled."
    
    # Remove existing vendor/gapps (conflicting proprietary files)
    rm -rf vendor/gapps
    
    echo "Cloning MindTheGapps vendor_gapps from GitLab (baklava)..."
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b baklava vendor/gapps
    
    # Fix ALL permissions in vendor/gapps
    echo "Setting executable permissions..."
    find vendor/gapps -name "*.sh" -exec chmod +x {} ;
    chmod +x vendor/gapps/setup-makefiles.py 2>/dev/null || true
    
    # Auto-integrate into device tree
    echo "Integrating GApps into device/xiaomi/renoir..."
    
    # Add to renoir.mk (Makefile include) - check first to avoid duplicates
    if ! grep -q "gapps/arm64/arm64-vendor.mk" device/xiaomi/renoir/renoir.mk; then
        {
            echo ""
            echo "# MindTheGapps (baklava)"
            echo "include vendor/gapps/arm64/arm64-vendor.mk"
        } >> device/xiaomi/renoir/renoir.mk
        echo "✓ Added GApps makefile include to renoir.mk"
    else
        echo "✓ GApps already included in renoir.mk"
    fi
    
    # Fix vendorsetup.sh permissions
    chmod +x device/xiaomi/renoir/vendorsetup.sh
    
    # Set GMS flag
    export WITH_GMS=true
    echo "WITH_GMS=true exported"
    
    echo "✅ GApps setup complete with permissions fixed!"
    echo "Next steps:"
    echo "  source build/envsetup.sh"
    echo "  source device/xiaomi/renoir/vendorsetup.sh" 
    echo "  brunch renoir user"
    
else
    echo "Gapps support disabled. Skipping ..."
    rm -rf vendor/gapps
    unset WITH_GMS
fi

# Apply custom patches if not already applied
if [ -f "frameworks/base/core/java/android/os/IPowerManager.aidl" ]; then
    if ! grep -q "rebootCustom" frameworks/base/core/java/android/os/IPowerManager.aidl; then
        echo -e "${color}Applying custom Renoir patches...${endcolor}"
        $(pwd)/device/xiaomi/renoir/apply_patches.sh
    else
        echo -e "${color}Custom Renoir patches already applied.${endcolor}"
    fi
fi

