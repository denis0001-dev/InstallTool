#!/bin/bash
if [[ $1 == *.AppImage ]] && [[ -e $1 ]]
then
  &>/dev/null
else
  echo "Error: the provided file is not an AppImage."
  exit 1
fi
file_path=$(realpath $1)
file_name=$(basename $1)
# Making the temporary installation dir
echo "Extracting the AppImage to the temporary folder..."
mkdir /tmp/appimage-install
cd /tmp/appimage-install
$file_path --appimage-extract 1>/dev/null
cd ./squashfs-root
# Copying the AppImage to the installation dir
echo "Copying the AppImage to the installation dir..."
mkdir ~/AppImages
cp $file_path ~/AppImages/$file_name
# Generating the desktop file
echo "Generating the desktop file..."
desktopfile=$(find . -type f -name '*.desktop')
source <(grep = $desktopfile | tr -d ' ')
echo "[Desktop Entry]" >> /usr/share/applications/$desktopfile
echo "Name=$Name" >> /usr/share/applications/$desktopfile
echo "Exec=sh -c ~/AppImages/$file_name" >> /usr/share/applications/$desktopfile
echo "Terminal=false" >> /usr/share/applications/$desktopfile
echo "Type=Application" >> /usr/share/applications/$desktopfile
echo "Icon=$Icon" >> /usr/share/applications/$desktopfile
echo "StartupWMClass=$StartupWMClass" >> /usr/share/applications/$desktopfile
echo "Comment=$Comment" >> /usr/share/applications/$desktopfile
echo "Categories=$Categories" >> /usr/share/applications/$desktopfile
# Generating the uninstall script
mkdir ~/AppImages/uninstall
echo "#!/bin/bash" >> ~/AppImages/uninstall/$Name.sh
echo "# Uninstall script for $Name." >> ~/AppImages/uninstall/$Name.sh
echo "if [ "$EUID" -ne 0 ]" >> ~/AppImages/uninstall/$Name.sh
echo "then" >> ~/AppImages/uninstall/$Name.sh
echo "  echo 'Error: you must run this as root.'" >> ~/AppImages/uninstall/$Name.sh
echo "fi" >> ~/AppImages/uninstall/$Name.sh
echo "rm /usr/share/applications/$desktopfile" >> ~/AppImages/uninstall/$Name.sh
echo "rm ~/AppImages/$file_name" >> ~/AppImages/uninstall/$Name.sh
echo "rm ~/AppImages/uninstall/$Name.sh" >> ~/AppImages/uninstall/$Name.sh
echo "echo 'Done.'" >> ~/AppImages/uninstall/$Name.sh
