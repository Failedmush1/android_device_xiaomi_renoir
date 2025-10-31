Gapps Setup
Prompts the user to enable or disable Gapps support during environment setup.
echo -e "${color}Setup Gapps ${end}"
read -p "Do you want to build with gapps support? (yes/no): " USER_INPUT
if [[ "USER_INPUT" =~ ^([yY][eE][sS]|[yY]) ]]; then
echo "Gapps support enabled."
echo "Cloning gapps source from crdroid gitlab..."
git clone --depth=1 https://gitlab.com/axionaosp/vendor_gapps -b tau vendor/gapps
else
echo "Gapps support disabled. Skipping ..."
rm -rf vendor/gapps
fi
--- CAMERA FIXES AND WORKAROUNDS ---
camera fixes
Combines the split proprietary MiuiCamera.apk files (MiuiCamera.apk.part*)
into a single, functional APK file required by the build system.
cat vendor/xiaomi/camera/proprietary/system/priv-app/MiuiCamera/MiuiCamera.apk.part* > vendor/xiaomi/camera/proprietary/system/priv-app/MiuiCamera/MiuiCamera.apk
Delete the line referencing the problematic 'libbinder_shim' dependency.
sed -i '/libbinder_shim/d' vendor/xiaomi/camera/Android.bp
Delete the line referencing the undefined 'android.hardware.graphics.common-V6-ndk' module.
sed -i '/android.hardware.graphics.common-V6-ndk/d' vendor/xiaomi/camera/Android.bp
Insert 'check_elf_files: false,' to bypass strict ELF file checking for libgui-xiaomi.
This prevents build errors for older/modified vendor libraries.
Check if the bypass line already exists
if ! grep -q 'check_elf_files: false,' vendor/xiaomi/camera/Android.bp; then
# If missing, find the module name line and insert the bypass on the next line.
sed -i '/name: "libgui-xiaomi",/a \    check_elf_files: false,' vendor/xiaomi/camera/Android.bp
fi