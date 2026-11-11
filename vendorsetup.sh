#!/bin/bash
# Auto-apply ROM patches for storage and media compatibility

DEVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${DEVICE_DIR}/apply-patches.sh" ]; then
    bash "${DEVICE_DIR}/apply-patches.sh"
fi
