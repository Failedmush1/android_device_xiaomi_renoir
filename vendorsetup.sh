#!/bin/bash

echo "Running vendorsetup.sh for renoir..."

# Apply sm8350-common patch
if ! grep -q "vendor/derp/config/device_framework_matrix.xml" device/xiaomi/sm8350-common/BoardConfigCommon.mk; then
    echo "Applying sm8350-common device framework matrix patch..."
    patch -d device/xiaomi/sm8350-common -p1 < device/xiaomi/renoir/0001-sm8350-common-Use-DerpFest-device-framework-matrix.patch
else
    echo "sm8350-common device framework matrix patch is already applied."
fi

# Apply vendor/derp patch
if ! grep -q "vendor/lineage-priv/keys/releasekey.pk8" vendor/derp/config/version.mk; then
    echo "Applying vendor/derp signed keys patch..."
    patch -d vendor/derp -p1 < device/xiaomi/renoir/0001-config-Use-lineage-priv-as-signed-keys.patch
else
    echo "vendor/derp signed keys patch is already applied."
fi
