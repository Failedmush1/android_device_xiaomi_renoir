#!/bin/bash
# crDroid renoir Build Script (EOF FIXED - Safe Vanilla + GApps)
set -e

echo "🚀 crDroid renoir Build Script (Xiaomi Mi 11 Lite 5G - SM8350)"
echo "============================================================"

# 🔥 INTERACTIVE GAPPS
read -p "Install GApps? (y/N): " -n 1 -r
echo
GAPPS=$([[ $REPLY =~ ^[Yy]$ ]] && echo 1 || echo 0)

if [ $GAPPS -eq 1 ]; then
    echo "✅ GApps + 6GB system resize enabled"
    RESIZE=1
else
    echo "✅ Vanilla build (default partitions - SAFE)"
    RESIZE=0
fi

# 1. BACKUP ORIGINALS
[ -f device/xiaomi/renoir/BoardConfig.mk.bak ] || cp device/xiaomi/renoir/BoardConfig.mk device/xiaomi/renoir/BoardConfig.mk.bak 2>/dev/null || true
[ -f device/xiaomi/renoir/lineage_renoir.mk.bak ] || cp device/xiaomi/renoir/lineage_renoir.mk device/xiaomi/renoir/lineage_renoir.mk.bak 2>/dev/null || true

# 2. GAPPS SETUP (if selected)
if [ $GAPPS -eq 1 ]; then
    rm -rf vendor/gapps
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
    echo "✅ GApps cloned"
    
    grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    sed -i '/vendor/gapps/d' device/xiaomi/renoir/lineage_renoir.mk 2>/dev/null || true
    cat >> device/xiaomi/renoir/lineage_renoir.mk << 'EOF'
# 🔥 MindTheGapps (Play Store + Core GApps)
$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
EOF
fi

# 3. DUPLICATE FIX (Always safe)
mkdir -p device/xiaomi/renoir/BoardConfig
cat > device/xiaomi/renoir/BoardConfig/override.mk << 'EOF'
# 🔥 Soong duplicate overrides (libjni_latinimegoogle.so)
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_PREBUILT_ELF_FILES := true
EOF

grep -q "override.mk" device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || \
echo -e "
include device/xiaomi/renoir/Board
