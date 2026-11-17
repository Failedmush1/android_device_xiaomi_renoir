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

# Apply 2026 LineageOS Security Patches to frameworks/base
if [ ! -f frameworks/base/.patch_applied_security_a15 ]; then
    if git -C frameworks/base apply --check ../../device/xiaomi/renoir/patches/0003-frameworks-base-Security-patches-A15.patch 2>/dev/null; then
        echo "Applying LineageOS 22.2 security patches to frameworks/base..."
        git -C frameworks/base apply ../../device/xiaomi/renoir/patches/0003-frameworks-base-Security-patches-A15.patch
    else
        echo "LineageOS security patches already in frameworks/base."
    fi
    touch frameworks/base/.patch_applied_security_a15
fi

# Apply Keybox attestation support patch to frameworks/base
if [ ! -f frameworks/base/.patch_applied_keybox_attestation ]; then
    if git -C frameworks/base apply --check ../../device/xiaomi/renoir/patches/0005-PropImitationHooks-Allow-Keybox-attestation-for-strong-integrity.patch 2>/dev/null; then
        echo "Applying Keybox attestation support patch to frameworks/base..."
        git -C frameworks/base apply ../../device/xiaomi/renoir/patches/0005-PropImitationHooks-Allow-Keybox-attestation-for-strong-integrity.patch
    else
        echo "Keybox attestation support already in frameworks/base."
    fi
    touch frameworks/base/.patch_applied_keybox_attestation
fi
