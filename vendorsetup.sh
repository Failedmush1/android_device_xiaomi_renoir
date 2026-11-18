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

# Automated feature patch loader for AOSPA (Credits: suvojeet-sengupta, kenway214)
renoir_apply_feature_patches() {
    local top="${T:-$(gettop)}"
    [ -z "$top" ] && top="$(pwd)"
    local repo="$top/device/xiaomi/renoir/patches"
    [ -d "$repo/features" ] || return 0

    echo "renoir: checking and applying feature patches (Credits: suvojeet-sengupta, kenway214)..." >&2

    for patches in $(for feature in "$repo"/features/*/; do
            echo "${feature}common" "${feature}aospa"
        done); do
        [ -d "$patches" ] || continue

        for patch in $(cd "$patches" && find . -name '*.patch' | sort); do
            patch="${patch#./}"
            local dir="$top/$(dirname "$patch")"
            [ -d "$dir" ] || continue

            # Check if patch is already applied
            if git -C "$dir" apply --check --reverse "$patches/$patch" &>/dev/null; then
                continue
            fi
            local subject="$(git mailinfo /dev/null /dev/null < "$patches/$patch" | sed -n 's/^Subject: //p')"
            if [ -n "$subject" ] && git -C "$dir" log -n 500 --format=%s 2>/dev/null | grep -Fxq -- "$subject"; then
                continue
            fi

            # Apply preserving original author and commit message
            if git -C "$dir" am -q --3way "$patches/$patch" &>/dev/null; then
                local author="$(git mailinfo /dev/null /dev/null < "$patches/$patch" | sed -n 's/^Author: //p')"
                echo "renoir: applied ${patches#"$repo/"}/$patch (Author: ${author:-suvojeet-sengupta})" >&2
            elif git -C "$dir" apply "$patches/$patch" &>/dev/null; then
                echo "renoir: applied via fallback ${patches#"$repo/"}/$patch" >&2
            else
                git -C "$dir" am --abort &>/dev/null
            fi
        done
    done
}

renoir_apply_feature_patches
unset -f renoir_apply_feature_patches
