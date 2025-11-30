#!/bin/bash
# crDroid renoir - RESIZE ONLY VANILLA (GApps = default)
set -e

clear
echo "🚀 crDroid renoir Build Script v2.1 (Vanilla 6GB Resize)"
echo "======================================================"

# INTERACTIVE
read -p "GApps? (y/N): " -n 1 -r
echo
GAPPS=$([[ $REPLY =~ ^[Yy]$ ]] && echo 1 || echo 0)

echo "${GAPPS:+✅ GApps (default resize)}${GAPPS:-✅ Vanilla + 6GB resize}"

# CLEANUP FIRST
rm -f device/xiaomi/renoir/vendorsetup.sh 2>/dev/null || true

# BACKUPS
cp -f device/xiaomi/renoir/BoardConfig.mk{,.bak} 2>/dev/null || true
cp -f device/xiaomi/renoir/lineage_renoir.mk{,.bak} 2>/dev/null || true

# GAPPS
if [ $GAPPS -eq 1 ]; then
    rm -rf vendor/gapps
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
    
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
fi

# DUPLICATE FIX
cat > device/xiaomi/renoir/BoardConfig/override.mk << 'EOFFIX'
# Soong duplicate fix
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_PREBUILT_ELF_FILES := true
EOFFIX

grep -q "override.mk" device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || \
echo -e "
include device/xiaomi/renoir/BoardConfig/override.mk" >> device/xiaomi/renoir/BoardConfig.mk

# 🔥 RESIZE ONLY VANILLA (GApps = device defaults)
sed -i '/BOARD_SUPER_PARTITION/,+5d' device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || true
if [ $GAPPS -eq 0 ]; then  # ← CHANGED: Vanilla only
    {
        echo ""
        echo "# 6GB VANILLA Resize (headroom for OTA/Magisk)"
        echo "BOARD_SUPER_PARTITION_SIZE         := 8589934592"
        echo "BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 4294967296"
        echo "BOARD_PRODUCTIMAGE_PARTITION_SIZE  := 2147483648"
    } >> device/xiaomi/renoir/BoardConfig.mk
    echo "✅ 6GB Vanilla resize applied"
else
    echo "✅ GApps = device default partitions"
fi

echo "✅ Config OK - Building..."
make clobber && source build/envsetup.sh && lunch lineage_renoir-user && m bacon | tee build.log

echo "🎉 $(ls -t out/target/product/renoir/*.zip | head -1)"
