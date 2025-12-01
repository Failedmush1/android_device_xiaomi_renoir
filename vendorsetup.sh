#!/bin/bash
# crDroid renoir v2.5 (WfdCommon + ALL Fixes)
set -e

clear
echo "🚀 crDroid renoir v2.5 (COMPLETE - WfdCommon FIXED)"
echo "=================================================="

# INTERACTIVE
read -p "GApps? (y/N): " -n 1 -r
echo
GAPPS=$([[ $REPLY =~ ^[Yy]$ ]] && echo 1 || echo 0)

echo "${GAPPS:+✅ GApps (default)}${GAPPS:-✅ Vanilla + 6GB resize}"

# 🔥 1. CREATE DIRECTORIES FIRST
mkdir -p device/xiaomi/renoir/BoardConfig

# 🔥 2. WFDCOMMON FIX (NEW - Prevents soong bootstrap failure)
echo "🔧 Fixing WfdCommon module..."
sed -i 's/WfdCommon,//g' frameworks/base/boot/Android.bp 2>/dev/null || true

# 🔥 3. DUPLICATE + MISSING MODULE FIXES
cat > device/xiaomi/renoir/BoardConfig/override.mk << 'EOF'
# Soong + WfdCommon fixes
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_PREBUILT_ELF_FILES := true
EOF

sed -i '/override.mk/d' device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || true
echo "include device/xiaomi/renoir/BoardConfig/override.mk" >> device/xiaomi/renoir/BoardConfig.mk

# 🔥 4. WiFi Tracker DISABLE
cat > device/xiaomi/renoir/renoir.prop << 'EOF'
# SetupWizard WiFi Tracker DISABLED
ro.setupwizard.feature.enable_wifi_tracker=false
ro.setupwizard.wifi_required=false
ro.setupwizard.network_required=false
ro.setupwizard.require_network=false
ro.setupwizard.mode=OPTIONAL
EOF

sed -i '/renoir.prop/d' device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || true
echo "TARGET_VENDOR_PROP += device/xiaomi/renoir/renoir.prop" >> device/xiaomi/renoir/BoardConfig.mk

# 🔥 5. GApps SETUP
if [ $GAPPS -eq 1 ]; then
    echo "📦 Cloning GApps..."
    rm -rf vendor/gapps
    git clone --depth=1 -b tau https://gitlab.com/MindTheGapps/vendor_gapps.git vendor/gapps
    
    grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    sed -i '/gapps/d' device/xiaomi/renoir/lineage_renoir.mk 2>/dev/null || true
    {
        echo ""
        echo "# MindTheGapps"
        echo '$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)'
        echo '$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)'
    } >> device/xiaomi/renoir/lineage_renoir.mk
    
    echo "PRODUCT_PACKAGES_REMOVE += libjni_latinimegoogle.so" >> device/xiaomi/renoir/lineage_renoir.mk
    echo "✅ GApps configured"
fi

# 🔥 6. VANILLA RESIZE ONLY
sed -i '/BOARD_SUPER_PARTITION/,+5d' device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || true
if [ $GAPPS -eq 0 ]; then
    {
        echo ""
        echo "# 6GB VANILLA Resize"
        echo "BOARD_SUPER_PARTITION_SIZE         := 8589934592"
        echo "BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 4294967296"
        echo "BOARD_PRODUCTIMAGE_PARTITION_SIZE  := 2147483648"
    } >> device/xiaomi/renoir/BoardConfig.mk
    echo "✅ 6GB Vanilla resize applied"
else
    echo "✅ GApps = device default partitions"
fi

echo "✅ ALL FIXES APPLIED - Building..."
make clobber && rm -rf out/soong/.bootstrap/ && source build/envsetup.sh && lunch lineage_renoir-user && m bacon

ROM_FILE=$(ls -t out/target/product/renoir/*.zip | head -1)
echo "🎉 BUILD COMPLETE: $ROM_FILE"
