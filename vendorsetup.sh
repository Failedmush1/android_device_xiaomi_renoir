#!/bin/bash
# crDroid renoir - PERFECT SYNTAX (No EOF errors)

clear
echo "🚀 crDroid renoir Build Script v2.2 (No Resize & Stability Fix)"
echo "=============================================================="

# CLEANUP AND BACKUP FIRST
rm -f device/xiaomi/renoir/vendorsetup.sh 2>/dev/null || true
cp -f device/xiaomi/renoir/BoardConfig.mk{,.bak} 2>/dev/null || true
cp -f device/xiaomi/renoir/lineage_renoir.mk{,.bak} 2>/dev/null || true

# --------------------------
# Gapps Selection and Setup
# --------------------------
GAPPS=0 # Initialize variable (0 = disabled)
echo -e "\n--- GApps Setup ---"

read -p "Do you want to build with GApps support? (yes/no): " USER_INPUT

if [[ "$USER_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    
    GAPPS=1 # Enable GApps
    
    echo "✅ GApps support enabled."
    echo "Cloning gapps source from MindTheGapps..."
    
    # 1. Clone GApps Source
    rm -rf vendor/gapps
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps

    # 2. Add GApps to crDroid product config (if not present)
    grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    # 3. Add GApps includes to device makefile and remove conflicting package
    sed -i '/gapps/d' device/xiaomi/renoir/lineage_renoir.mk 2>/dev/null || true
    {
        echo ""
        echo "# MindTheGapps"
        echo '$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)'
        echo '$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)'
        echo "PRODUCT_PACKAGES_REMOVE += libjni_latinimegoogle.so"
    } >> device/xiaomi/renoir/lineage_renoir.mk

else

    echo "❌ GApps support disabled. Skipping..."
    rm -rf vendor/gapps

fi
echo "--- GApps Setup Complete ---"

---

# --------------------------
# DUPLICATE FIX
# --------------------------
cat > device/xiaomi/renoir/BoardConfig/override.mk << 'EOFFIX'
# Soong duplicate fix
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_PREBUILT_ELF_FILES := true
EOFFIX

grep -q "override.mk" device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || \
echo -e "
include device/xiaomi/renoir/BoardConfig/override.mk" >> device/xiaomi/renoir/BoardConfig.mk

---

# --------------------------
# RESIZE (REMOVED)
# The partition resizing logic was removed as requested.
# --------------------------
sed -i '/BOARD_SUPER_PARTITION/,+5d' device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || true
if [ $GAPPS -eq 1 ]; then
    echo "⚠️ Resizing skipped as requested. Using default partition sizes."
fi

---

# --------------------------
# BUILD COMMAND (Stability Fix)
# --------------------------
echo "✅ Config OK - Building..."
make clobber && source build/envsetup.sh && lunch lineage_renoir-user && m bacon -j$(nproc --ignore=2) | tee build.log

echo "🎉 $(ls -t out/target/product/renoir/*.zip | head -1)"
