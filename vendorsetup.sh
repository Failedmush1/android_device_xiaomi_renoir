#!/bin/bash

# Apply 4G Icon patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_4g_icon ]; then
    echo "Applying 4G icon patch to frameworks/base..."
    cd frameworks/base
    git apply ../../device/xiaomi/renoir/patches/0001-telephony-Default-to-showing-4G-icon-instead-of-LTE.patch
    touch .patch_applied_4g_icon
    cd ../..
else
    echo "4G icon patch already applied to frameworks/base."
fi

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
