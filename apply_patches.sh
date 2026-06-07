#!/bin/bash

# Pre-build Framework Patcher for renoir
# This script applies necessary framework patches stored in the device tree.

PROJECT_ROOT=$(pwd)
PATCH_DIR="device/xiaomi/renoir/patches"

echo "Checking for framework patches in $PATCH_DIR..."

if [ -d "$PATCH_DIR" ]; then
    for patch in "$PATCH_DIR"/*.patch; do
        if [ -f "$patch" ]; then
            echo "Processing patch: $(basename "$patch")"
            
            # Determine target directory from the first line of the patch
            TARGET_FILE=$(grep -m 1 "^--- a/" "$patch" | sed 's|^--- a/||')
            
            if [ -z "$TARGET_FILE" ]; then
                echo "Could not determine target file for $patch, skipping..."
                continue
            fi

            # Find which repo the file belongs to
            # This logic assumes the standard Android build structure
            if [[ "$TARGET_FILE" == media/codec2/* ]]; then
                TARGET_REPO="frameworks/av"
            elif [[ "$TARGET_FILE" == services/surfaceflinger/* ]]; then
                TARGET_REPO="frameworks/native"
            else
                # Fallback: try to guess or use frameworks/av as default
                TARGET_REPO="frameworks/av"
            fi

            echo "Target Repo: $TARGET_REPO"
            
            if [ -d "$PROJECT_ROOT/$TARGET_REPO" ]; then
                cd "$PROJECT_ROOT/$TARGET_REPO"
                patch -p1 --forward --dry-run < "$PROJECT_ROOT/$patch" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    patch -p1 --forward < "$PROJECT_ROOT/$patch"
                    echo "Successfully applied $(basename "$patch")"
                else
                    echo "Patch $(basename "$patch") was already applied or failed (dry-run)."
                fi
                cd "$PROJECT_ROOT"
            else
                echo "Repository $TARGET_REPO not found, skipping $patch"
            fi
        fi
    done
else
    echo "No patches found."
fi
