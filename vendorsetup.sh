# Gapps

echo -e "${color}Setup Gapps ${end}"

read -p "Do you want to build with gapps support? (yes/no): " USER_INPUT

if [[ "$USER_INPUT" =~ ^([yY][eE][sS]|[yY])$ ]]; then

echo "Gapps support enabled."

echo "Cloning gapps source from crdroid gitlab..."

git clone --depth=1 https://gitlab.com/MindTheGapps/vendor_gapps -b baklava vendor/gapps

else

echo "Gapps support disabled. Skipping ..."

rm -rf vendor/gapps

fi
