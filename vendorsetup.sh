#!/bin/bash

# Apply NFC Statusbar Icon patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_nfc_icon ]; then
    echo "Applying NFC Statusbar Icon patch to frameworks/base..."
    cd frameworks/base
    git apply ../../device/xiaomi/renoir/patches/0002-SystemUI-Add-status-bar-NFC-icon.patch
    touch .patch_applied_nfc_icon
    cd ../..
else
    echo "NFC Statusbar Icon patch already applied to frameworks/base."
fi

# Apply VoLTE & VoWiFi Statusbar Icons patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_volte_icon ]; then
    echo "Applying VoLTE & VoWiFi Statusbar Icons patch to frameworks/base..."
    cd frameworks/base
    git apply ../../device/xiaomi/renoir/patches/0003-SystemUI-Introduce-dynamic-VoLTE-VoWiFi-icons.patch
    touch .patch_applied_volte_icon
    cd ../..
else
    echo "VoLTE & VoWiFi Statusbar Icons patch already applied to frameworks/base."
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

# Apply camera sepolicy patch
if ! grep -q "platform_app)" vendor/xiaomi/camera/sepolicy/vendor/hal_camera_default.te; then
    echo "Applying camera sepolicy patch..."
    patch -d vendor/xiaomi/camera -p1 < device/xiaomi/renoir/patches/0006-camera-Fix-sepolicy-error-for-platform_app_all.patch
else
    echo "camera sepolicy patch is already applied."
fi

# Apply hardware/lineage/compat patch
if [ -d "hardware/lineage/compat" ] && ! grep -q "libstagefright_foundation-v33" hardware/lineage/compat/Android.bp 2>/dev/null; then
    echo "Applying hardware/lineage/compat libstagefright_foundation-v33 patch..."
    cd hardware/lineage/compat
    git apply ../../../device/xiaomi/renoir/patches/0007-compat-Provide-libstagefright_foundation-v33.patch
    cd ../../..
else
    echo "hardware/lineage/compat libstagefright_foundation-v33 patch is already applied or repo missing."
fi
