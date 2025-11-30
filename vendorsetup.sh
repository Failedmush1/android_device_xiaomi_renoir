if [[ "$USER_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Gapps support enabled."
    if [ -d "vendor/gapps" ]; then
        rm -rf vendor/gapps
    fi
    echo "Cloning gapps source from crdroid gitlab..."
    git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b tau vendor/gapps
    
    # Add Soong export for vendor/gapps
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> device/*/AndroidProducts.mk || \
    echo "PRODUCT_SOONG_NAMESPACES += vendor/gapps" >> vendor/lineage/config/crdroid.mk
    
    echo "GApps Soong namespace exported."
else
    echo "Gapps support disabled. Skipping ..."
    rm -rf vendor/gapps
fi
