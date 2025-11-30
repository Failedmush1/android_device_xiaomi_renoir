#!/bin/bash
# crDroid renoir GApps Build Script (libjni_latinimegoogle.so FIXED)
set -e

echo "🚀 Starting crDroid GApps Build for Xiaomi renoir (SM8350)"

# 1. GApps Clone
rm -rf vendor/gapps
git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
echo "✅ GApps cloned"

# 2. Soong Namespace
grep -q "vendor/gapps" vendor/lineage/config/crdroid.mk 2>/dev/null || \
echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
echo "✅ Soong namespace added"

# 3. GApps Makefiles
cat >> device/xiaomi/renoir/lineage_renoir.mk << 'EOF'

# MindTheGapps (Play Store + GApps)
$(call inherit-product-if-exists, vendor/gapps/common/common-vendor.mk)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
EOF
echo "✅ GApps makefiles added"

# 4. 🔥 TERMINAL DUPLICATE FIX (BoardConfig - EARLIEST loading)
mkdir -p device/xiaomi/renoir/BoardConfig
cat > device/xiaomi/renoir/BoardConfig/override.mk << 'EOF'
# 🔥 TERMINAL Soong duplicate overrides (libjni_latinimegoogle.so)
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_PREBUILT_ELF_FILES := true
EOF

grep -q "override.mk" device/xiaomi/renoir/BoardConfig.mk 2>/dev/null || \
echo -e "
include device/xiaomi/renoir/BoardConfig/override.mk" >> device/xiaomi/renoir/BoardConfig.mk

echo 'PRODUCT_PACKAGES_REMOVE += libjni_latinimegoogle.so' >> device/xiaomi/renoir/lineage_renoir.mk
echo "✅ BoardConfig overrides + package removal"

# 5. Verify
echo "🔍 Verification:"
grep -n "vendor/gapps" device/xiaomi/renoir/lineage_renoir.mk
grep "BUILD_BROKEN" device/xiaomi/renoir/BoardConfig/override.mk
echo "✅ Config verified"

# 6. NUCLEAR CLEAN + BUILD
echo "💥 Nuclear clean + building..."
make clobber
source build/envsetup.sh && lunch lineage_renoir-user && m bacon | tee build_$(date +%Y%m%d_%H%M%S).log

echo "🎉 Build complete! Check out/target/product/renoir/lineage_renoir-*.zip"
