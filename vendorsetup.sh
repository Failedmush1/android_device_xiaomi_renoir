# Gapps

echo -e "${color}Setup Gapps ${end}"

read -p "Do you want to build with gapps support? (yes/no): " USER_INPUT

if [[ "$USER_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then

echo "Gapps support enabled."

echo "Cloning gapps source from crdroid gitlab..."

git clone --depth=1 https://gitlab.com/crdroidandroid/android-vendor-gapps-spes.git -b 13.0 vendor/gapps

else

echo "Gapps support disabled. Skipping ..."

rm -rf vendor/gapps

fi


