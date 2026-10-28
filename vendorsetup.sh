# Auto-apply patches for renoir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_ROOT="$SCRIPT_DIR/patches"

# Determine Android root directory
if type gettop >/dev/null 2>&1 && [ -n "$(gettop)" ]; then
    ANDROID_ROOT="$(gettop)"
else
    ANDROID_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

apply_patches() {
    local target_rel=$1
    local patch_subdir=$2
    local target_dir="$ANDROID_ROOT/$target_rel"
    local full_patch_path="$PATCH_ROOT/$patch_subdir"

    if [ -d "$full_patch_path" ] && [ -d "$target_dir" ]; then
        echo "Checking patches for $target_rel..."
        for patch in "$full_patch_path"/*.patch; do
            [ -f "$patch" ] || continue
            local patch_name
            patch_name="$(basename "$patch")"
            if git -C "$target_dir" apply --reverse --check "$patch" > /dev/null 2>&1; then
                echo "Patch $patch_name already applied to $target_rel, skipping."
            else
                if git -C "$target_dir" am -3 "$patch" > /dev/null 2>&1; then
                    echo "Successfully applied $patch_name to $target_rel"
                else
                    echo "Failed to apply $patch_name to $target_rel - check for conflicts!"
                    git -C "$target_dir" am --abort > /dev/null 2>&1
                fi
            fi
        done
    fi
}

# Apply framework patches (from patches/ root or patches/frameworks_base)
apply_patches "frameworks/base" ""
# Apply vendor patches
apply_patches "vendor/halcyon" "vendor"

