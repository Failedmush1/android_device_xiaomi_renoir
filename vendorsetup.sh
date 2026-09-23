#!/bin/bash

DEVICE_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FW_BASE="$DEVICE_PATH/../../../frameworks/base"

# Apply 4G Icon patch to frameworks/base
if [ ! -f "$FW_BASE/.patch_applied_4g_icon" ]; then
    echo "Applying 4G icon patch to frameworks/base..."
    if git -C "$FW_BASE" apply "$DEVICE_PATH/patches/0001-telephony-Default-to-showing-4G-icon-instead-of-LTE.patch"; then
        touch "$FW_BASE/.patch_applied_4g_icon"
    else
        echo "Failed to apply 4G icon patch to frameworks/base."
    fi
else
    echo "4G icon patch already applied to frameworks/base."
fi

# Apply NFC Statusbar Icon patch to frameworks/base
if [ ! -f "$FW_BASE/.patch_applied_nfc_icon" ]; then
    echo "Applying NFC Statusbar Icon patch to frameworks/base..."
    if git -C "$FW_BASE" apply "$DEVICE_PATH/patches/0002-SystemUI-Add-status-bar-NFC-icon.patch"; then
        touch "$FW_BASE/.patch_applied_nfc_icon"
    else
        echo "Failed to apply NFC Statusbar Icon patch to frameworks/base."
    fi
else
    echo "NFC Statusbar Icon patch already applied to frameworks/base."
fi
