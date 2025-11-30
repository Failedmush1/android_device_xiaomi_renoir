#!/bin/bash
# crDroid renoir Build Script (ALWAYS 6GB System + GApps Option + Duplicate Fix)
set -e

echo "🚀 crDroid renoir Build Script (Xiaomi Mi 11 Lite 5G - SM8350)"
echo "============================================================"
echo "✅ ALWAYS 6GB system space (GApps + Vanilla optimized)"

# 🔥 INTERACTIVE GAPPS
read -p "Install GApps? (y/N): " -n 1 -r
echo
GAPPS=$([[ $REPLY =~ ^[Yy]$ ]] && echo 1 || echo 0)

[ $GAPPS -eq 1 ] && echo "✅ GApps enabled" || echo "✅ Vanilla build"

# 1. BACKUP ORIGINALS
[ -f device/xiaomi/renoir/BoardConfig.mk.bak ] || cp device/xiaomi/renoir/BoardConfig.mk device/xiaomi/renoir/BoardConfig.mk.bak
[ -f device/xiaomi/renoir/lineage_renoir.mk.bak ] || cp device/xiaomi/renoir/lineage_renoir.mk device/xiaomi/renoir/lineage_renoir.mk.bak

# 2. GAPPS SETUP (if selected)
if [ $GAPPS -eq 1 ]; then
    rm -rf vendor/gapps
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
    echo "✅ GApps cloned (MindTheGapps)"
    
    # Soong namespace
    grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    # GApps makefiles (clean slate)
    sed -i '/vendor/gapps/d' device/xiaomi/renoir/lineage_renoir.mk 2>/dev/null
    cat >> device/xiaomi/renoir/lineage_renoir.mk << 'EOF'

# 🔥 MindTheGapps (Play Store + Core GApps)
$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
EOF
fi

# 3. 🔥 DUPLICATE FIX (Always safe)
mkdir -p device/xiaomi/renoir/BoardConfig
cat > device
