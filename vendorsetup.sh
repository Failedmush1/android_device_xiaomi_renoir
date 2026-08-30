# Auto-apply patches for renoir
PATCH_ROOT="device/xiaomi/renoir/patches"

apply_patches() {
    local target_dir=$1
    local patch_subdir=$2
    local full_patch_path="$PATCH_ROOT/$patch_subdir"

    if [ -d "$full_patch_path" ]; then
        echo "Checking patches for $target_dir..."
        for patch in "$full_patch_path"/*.patch; do
            if patch -p1 --dry-run -R -d "$target_dir" < "$patch" > /dev/null 2>&1; then
                echo "Patch $(basename "$patch") already applied to $target_dir, skipping."
            else
                if git -C "$target_dir" am "$PWD/$patch" > /dev/null 2>&1; then
                    echo "Successfully applied $(basename "$patch") to $target_dir"
                else
                    echo "Failed to apply $(basename "$patch") to $target_dir - check for conflicts!"
                    git -C "$target_dir" am --abort
                fi
            fi
        done
    fi
}

# Apply framework patches (from patches/ root)
apply_patches "frameworks/base" ""
