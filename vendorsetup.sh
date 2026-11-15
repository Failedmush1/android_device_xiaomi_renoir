#!/bin/bash

# Apply 4G Icon patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_4g_icon ]; then
    if git -C frameworks/base apply --check ../../device/xiaomi/renoir/patches/0001-telephony-Default-to-showing-4G-icon-instead-of-LTE.patch 2>/dev/null; then
        echo "Applying 4G icon patch to frameworks/base..."
        git -C frameworks/base apply ../../device/xiaomi/renoir/patches/0001-telephony-Default-to-showing-4G-icon-instead-of-LTE.patch
    else
        echo "4G icon already in frameworks/base."
    fi
    touch frameworks/base/.patch_applied_4g_icon
fi

# Apply NFC Statusbar Icon patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_nfc_icon ]; then
    if git -C frameworks/base apply --check ../../device/xiaomi/renoir/patches/0002-SystemUI-Add-status-bar-NFC-icon.patch 2>/dev/null; then
        echo "Applying NFC Statusbar Icon patch to frameworks/base..."
        git -C frameworks/base apply ../../device/xiaomi/renoir/patches/0002-SystemUI-Add-status-bar-NFC-icon.patch
    else
        echo "NFC icon patch skipped (not applicable or already present)."
    fi
    touch frameworks/base/.patch_applied_nfc_icon
fi
