#!/bin/bash
# Checking that the specified file exists and it's an AppImage
if [[ $1 == *.AppImage ]]
then
echo "This file is an AppImage"
else
failappimage = true
echo "Error: This file is not an AppImage."
fi
if [[ -e $1 ]]
then
echo "File exists."
else
failexist = true
echo "This file doesn't exist."
fi
if [[ $failexist = true ]] && [[ $failappimage = true ]]
then
  echo "Error: the provided file is not an AppImage."
  exit 1
fi
# Checking that this program was ran as sudo, not directly as root
if [[ $(env | grep SUDO_USER) = "SUDO_USER=root" ]]
then
  echo "Error: root user is not supported! Use sudo installtool appimage ... instead."
  exit 1
fi
# Variables
file_path=$(realpath $1)
file_name=$(basename $1)
home_path="/home/$(echo $(env | grep SUDO_USER) | sed 's/SUDO_USER=//')"
if [[ $home_path = "/home/" ]]
then
  echo "Error: home path doesn't exist, try again with sudo."
  exit 1
fi
# Clearing temporary files
rm -rf /tmp/appimage-install
# Making the temporary installation dir
echo "Extracting the AppImage to the temporary folder..."
mkdir /tmp/appimage-install &>/dev/null
cd /tmp/appimage-install
chmod +x $file_path
$file_path --appimage-extract 1>/dev/null
cd ./squashfs-root
# Copying the AppImage to the installation dir
echo "Copying the AppImage to the installation dir..."
mkdir $home_path/AppImages &>/dev/null
cp $file_path $home_path/AppImages/$file_name

# Generating the desktop file
echo "Generating the desktop file..."
desktopfile=$(basename $(find . -maxdepth 1 -type f -name '*.desktop' )) &>/dev/null
source <(grep = $desktopfile | tr -d ' ') &>/dev/null
# Copying the icon
cd ..
icon_path=$(realpath $(find -L . -type f -wholename "./squashfs-root/$Icon*" | grep -e '.png' -e '.svg')) &>/dev/null
mkdir $home_path/AppImages/icons &>/dev/null
cp $icon_path $home_path/AppImages/icons/$(basename $icon_path)
cd squashfs-root
echo "[Desktop Entry]" >> /usr/share/applications/$desktopfile
echo $(cat ./$desktopfile | grep 'Name=') >> /usr/share/applications/$desktopfile
echo "Exec=sh -c $home_path/AppImages/$file_name" >> /usr/share/applications/$desktopfile
echo "Terminal=false" >> /usr/share/applications/$desktopfile
echo "Type=Application" >> /usr/share/applications/$desktopfile
echo "Icon=$home_path/AppImages/icons/$(basename $icon_path)" >> /usr/share/applications/$desktopfile
echo "StartupWMClass=$StartupWMClass" >> /usr/share/applications/$desktopfile
echo $(cat ./$desktopfile | grep 'Comment=') >> /usr/share/applications/$desktopfile
echo "Categories=$Categories" >> /usr/share/applications/$desktopfile
# Generating the uninstall script
mkdir $home_path/AppImages/uninstall &>/dev/null
echo "#!/bin/bash" >> $home_path/AppImages/uninstall/$Name.sh
echo "# Uninstall script for $Name." >> $home_path/AppImages/uninstall/$Name.sh
echo 'if [ "$EUID" -ne 0 ]' >> $home_path/AppImages/uninstall/$Name.sh
echo "then" >> $home_path/AppImages/uninstall/$Name.sh
echo "  echo 'Error: you must run this as root.'" >> $home_path/AppImages/uninstall/$Name.sh
echo "fi" >> $home_path/AppImages/uninstall/$Name.sh
echo "rm /usr/share/applications/$desktopfile" >> $home_path/AppImages/uninstall/$Name.sh
echo "rm $home_path/AppImages/$file_name" >> $home_path/AppImages/uninstall/$Name.sh
echo "rm $home_path/AppImages/uninstall/$Name.sh" >> $home_path/AppImages/uninstall/$Name.sh
echo "rm $home_path/AppImages/icons/$(basename $icon_path)" >> $home_path/AppImages/uninstall/$Name.sh
echo "echo 'Done.'" >> $home_path/AppImages/uninstall/$Name.sh
chmod +x $home_path/AppImages/uninstall/$Name.sh
rm -rf /tmp/appimage_install
