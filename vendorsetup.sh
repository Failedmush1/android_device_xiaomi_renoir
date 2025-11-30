#!/bin/bash
# crDroid renoir Build Script (Interactive GApps + libjni_latinimegoogle.so FIXED)
set -e

echo "🚀 crDroid Build Script for Xiaomi renoir (SM8350)"
echo "=================================================="

# 🔥 INTERACTIVE GAPPS PROMPT
read -p "Do you want GApps? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ GApps enabled - installing MindTheGapps + fixes"
    GAPPS=1
else
    echo "❌ GApps disabled - vanilla build"
    GAPPS=0
fi

# 1. GApps (if selected)
if [ $GAPPS -eq 1 ]; then
    rm -rf vendor/gapps
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
    echo "✅ GApps cloned"
    
    # Soong namespace
    grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    # GApps makefiles
    cat >> device/xiaomi/renoir/lineage_renoir.mk << 'EOF'

# MindTheGapps (Play Store + GApps)
$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
EOF
fi

# 2. 🔥 DUPLICATE FIX (always - safe even for vanilla)
mkdir -p device/xiaomi/renoir/BoardConfig
cat > device/xiaomi/renoir/BoardConfig/override.mk << 'EOF'
# 🔥 Soong duplicate overrides (libjni_latinimegoogle.so - safe for all builds)
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_PREBUILT_ELF_FILES := true
EOF

grep -q "override.mk" device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || \
echo -e "
include device/xiaomi/renoir/BoardConfig/override.mk" >> device/xiaomi/renoir/BoardConfig.mk

if [ $GAPPS -eq 1 ]; then
    echo 'PRODUCT_PACKAGES_REMOVE += libjni_latinimegoogle.so' >> device/xiaomi/renoir/lineage_renoir.mk
fi

echo "✅ Build config applied"

# 3. BUILD
echo "💥 Cleaning + building..."
make clobber
source build/envsetup.sh && lunch lineage_renoir-user && m bacon | tee build_$(date +%Y%m%d_%H%M%S).log

if [ $GAPPS -eq 1 ]; then
    echo "🎉 GApps crDroid ready! out/target/product/renoir/lineage_renoir-*.zip (~1.8GB)"
    echo "   → Flash → Factory reset → Play Store ready"
else
    echo "🎉 Vanilla crDroid ready! out/target/product/renoir/lineage_renoir-*.zip (~1.2GB)"
    echo "   → Flash → No reset needed"
fi
