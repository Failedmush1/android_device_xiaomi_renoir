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
    git apply ../../device/xiaomi/renoir/patches/0004-SystemUI-Add-Show-4G-instead-of-LTE-tuner-setting.patch
    touch .patch_applied_show_fourg_tuner
    cd ../..
else
    echo "Show 4G instead of LTE tuner setting patch already applied to frameworks/base."
fi
