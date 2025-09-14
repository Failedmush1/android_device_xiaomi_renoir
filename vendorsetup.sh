echo 'Cloning stuff needed to build for renoir'
# Leica patch
echo 'Adding Leica camera patch'
cd frameworks/base
wget https://raw.githubusercontent.com/xiaomi-haydn-devs/Patch-Haydn/14/Leicamera/0001-Add-backwards-compatible-CaptureResultExtras-constructor.patch
patch -p1 <0001-Add-backwards-compatible-CaptureResultExtras-constructor.patch
cd ../..

echo 'delete vendorsetup.sh from device tree once this is done'