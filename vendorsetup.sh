#!/bin/bash
# crDroid renoir Build Script (GApps + 6GB System Resize + libjni_latinimegoogle FIXED)
set -e

echo "🚀 crDroid renoir Build Script (Xiaomi Mi 11 Lite 5G - SM8350)"
echo "============================================================"

# 🔥 INTERACTIVE GAPPS + RESIZE PROMPT
read -p "Install GApps? (y/N): " -n 1 -r
echo
GAPPS=$([[ $REPLY =~ ^[Yy]$ ]] && echo 1 || echo 0)

if [ $GAPPS -eq 1 ]; then
    echo "✅ GApps enabled (MindTheGapps)"
    read -p "Increase system to 6GB? (y/N): " -n 1 -r
    echo
    RESIZE=$([[ $REPLY =~ ^[Yy]$ ]] && echo 1 || echo 0)
else
    echo "✅ Vanilla build (no resize needed)"
    RESIZE=0
fi

# 1. BACKUP ORIGINALS
[ -f device/xiaomi/renoir/BoardConfig.mk.bak ] || cp device/xiaomi/renoir/BoardConfig.mk device/xiaomi/renoir/BoardConfig.mk.bak
[ -f device/xiaomi/renoir/lineage_renoir.mk.bak ] || cp device/xiaomi/renoir/lineage_renoir.mk device/xiaomi/renoir/lineage_renoir.mk.bak

# 2. GAPPS SETUP
if [ $GAPPS -eq 1 ]; then
    rm -rf vendor/gapps
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
    echo "✅ GApps cloned"
    
    # Soong namespace
    grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    # GApps makefiles (remove existing first)
    sed -i '/vendor/gapps/d' device/xiaomi/renoir/lineage_renoir.mk 2>/dev/null
    cat >> device/xiaomi/renoir/lineage_renoir.mk << 'EOF'

# 🔥 MindTheGapps (Play Store + Core GApps)
$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
EOF
fi

# 3. 🔥 DUPLICATE FIX (Always - safe for all
