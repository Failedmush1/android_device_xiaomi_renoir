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


# Apply 2026 Security Patches to frameworks/base
if [ ! -f frameworks/base/.patch_applied_security_2026 ]; then
    if git -C frameworks/base apply --check ../../device/xiaomi/renoir/patches/0003-frameworks-base-Security-patches-2026.patch 2>/dev/null; then
        echo "Applying 2026 security patches to frameworks/base..."
        git -C frameworks/base apply ../../device/xiaomi/renoir/patches/0003-frameworks-base-Security-patches-2026.patch
    else
        echo "2026 security patches already in frameworks/base."
    fi
    touch frameworks/base/.patch_applied_security_2026
fi

# Apply hardware/lineage/compat patch
if [ -d "hardware/lineage/compat" ] && ! grep -q "libstagefright_foundation-v33" hardware/lineage/compat/Android.bp 2>/dev/null; then
    echo "Applying hardware/lineage/compat libstagefright_foundation-v33 patch..."
    patch -d hardware/lineage/compat -p1 < device/xiaomi/renoir/patches/0007-compat-Provide-libstagefright_foundation-v33.patch
else
    echo "hardware/lineage/compat libstagefright_foundation-v33 patch is already applied or repo missing."
fi
