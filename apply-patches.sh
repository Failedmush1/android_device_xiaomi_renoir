#!/bin/bash
# Script to automatically apply ROM patches for storage and media compatibility

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

apply_patch() {
    local target_dir="$1"
    local patch_file="$2"

    if [ ! -d "${ROOT_DIR}/${target_dir}" ] || [ ! -f "${patch_file}" ]; then
        return 0
    fi

    # Check if already applied (reverse check succeeds if patch is already applied)
    if git -C "${ROOT_DIR}/${target_dir}" apply --reverse --check "${patch_file}" >/dev/null 2>&1; then
        return 0
    fi

    # Check if patch applies cleanly
    if git -C "${ROOT_DIR}/${target_dir}" apply --check "${patch_file}" >/dev/null 2>&1; then
        echo "[renoir] Applying $(basename "${patch_file}") to ${target_dir}..."
        git -C "${ROOT_DIR}/${target_dir}" apply "${patch_file}"
    else
        echo "[renoir] Warning: Patch $(basename "${patch_file}") could not be applied cleanly to ${target_dir}."
    fi
}

apply_patch "system/vold" "${SCRIPT_DIR}/patches/system_vold/0001-vold-set-0777-app-dirs-mode.patch"
apply_patch "frameworks/base" "${SCRIPT_DIR}/patches/frameworks_base/0001-StorageManagerService-fix-legacy-storage.patch"
apply_patch "packages/providers/MediaProvider" "${SCRIPT_DIR}/patches/packages_providers_MediaProvider/0001-MediaProvider-allow-legacy-apps-media-read.patch"

exit 0
