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

# Fix duplicate fm module error by removing the prebuilt copy
echo "Removing prebuilt vendor.qti.hardware.fm@1.0.so from vendor/xiaomi/sm8350-common..."
sed -i '/vendor\.qti\.hardware\.fm@1\.0\.so/d' vendor/xiaomi/sm8350-common/sm8350-common-vendor.mk

# Apply vendor/derp WITH_GMS override patch
if ! grep -q "ifeq (\$(WITH_GMS),true)" vendor/derp/config/common.mk; then
    echo "Applying vendor/derp WITH_GMS override patch..."
    patch -d vendor/derp -p1 < device/xiaomi/renoir/0001-config-Allow-overriding-WITH_GMS-flag.patch
else
    echo "vendor/derp WITH_GMS override patch is already applied."
fi

# Apply camera sepolicy patch
if ! grep -q "platform_app)" vendor/xiaomi/camera/sepolicy/vendor/hal_camera_default.te; then
    echo "Applying camera sepolicy patch..."
    patch -d vendor/xiaomi/camera -p1 < device/xiaomi/renoir/0001-camera-Fix-sepolicy-error-for-platform_app_all.patch
else
    echo "camera sepolicy patch is already applied."
fi

# Apply crDroid apns-conf.xml patch
if ! grep -q "Copyright 2016-2024 The LineageOS Project" vendor/derp/prebuilt/common/etc/apns-conf.xml; then
    echo "Applying crDroid apns-conf.xml patch..."
    patch -d vendor/derp -p1 < device/xiaomi/renoir/0001-prebuilt-Update-apns-conf.xml-from-crDroid.patch
else
    echo "crDroid apns-conf.xml patch is already applied."
fi

# Apply Show 4G instead of LTE tuner setting patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_show_fourg_tuner ]; then
    echo "Applying Show 4G instead of LTE tuner setting patch to frameworks/base..."
    cd frameworks/base
    git apply ../../device/xiaomi/renoir/patches/0004-SystemUI-Add-Show-4G-instead-of-LTE-tuner-setting.patch || true
    git apply ../../device/xiaomi/renoir/patches/0005-SystemUI-Allow-using-4G-icon-instead-of-LTE.patch || true
    touch .patch_applied_show_fourg_tuner
    cd ../..
else
    echo "Show 4G instead of LTE tuner setting patch already applied to frameworks/base."
fi

if [ -d "hardware/lineage/compat" ] && ! grep -q "libstagefright_foundation-v33" hardware/lineage/compat/Android.bp 2>/dev/null; then
    echo "Applying hardware/lineage/compat libstagefright_foundation-v33 patch..."
    patch -d hardware/lineage/compat -p1 < device/xiaomi/renoir/0001-compat-Provide-libstagefright_foundation-v33.patch
else
    echo "hardware/lineage/compat libstagefright_foundation-v33 patch is already applied or repo missing."
fi

