echo -e "${color}Setup Gapps ${endcolor}"

read -p "Do you want to build with gapps support? (yes/no): " USER_INPUT

if [[ "$USER_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Gapps support enabled."
    
    # Remove existing vendor/gapps (conflicting proprietary files)
    rm -rf vendor/gapps
    
    echo "Cloning MindTheGapps vendor_gapps from GitLab (baklava)..."
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b baklava vendor/gapps
    
    # Auto-integrate into device tree
    echo "Integrating GApps into device/xiaomi/renoir..."
    
    # Add to renoir.mk (Makefile include)
    if ! grep -q "gapps/arm64/arm64-vendor.mk" device/xiaomi/renoir/renoir.mk; then
        echo "" >> device/xiaomi/renoir/renoir.mk
        echo "# MindTheGapps" >> device/xiaomi/renoir/renoir.mk
        echo "include vendor/gapps/arm64/arm64-vendor.mk" >> device/xiaomi/renoir/renoir.mk
        echo "✓ Added GApps makefile include"
    fi
    
    # Set GMS flag
    export WITH_GMS=true
    
    echo "✅ GApps setup complete. Use: brunch renoir"
    
else
    echo "Gapps support disabled. Skipping ..."
    rm -rf vendor/gapps
    unset WITH_GMS
fi
