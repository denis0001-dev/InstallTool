#!/bin/bash
# Add x32 architecture
echo "Adding x32 architecture..."
dpkg --add-architecture i386 
# Download the repository key
echo "Downloading the repository key..."
mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
echo "Downloading the apt sources..."
# Detect the distrubutition and download the sources
case $(lsb_release -i -s) in
  "Ubuntu")
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -c -s)/winehq-$(lsb_release -c -s).sources
    ;;
  "Debian")
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -c -s)/winehq-$(lsb_release -c -s).sources
    ;;
  *)
    echo "Error: this distributition is not supported!"
    exit 1
esac
echo "Updating the package information..."
apt update
echo "Installing Wine..."
result=$(dialog --menu "Choose the WineHQ branch:" 12 45 25 1 "Stable" 2 "Staging" 3 "Development" 2>&1 1>&3)
case result in
  1)
    apt install --install-recommends winehq-stable
    ;;
  2)
    apt install --install-recommends winehq-devel
    ;;
  3)
    apt install --install-recommends winehq-staging
    ;;
  *)
    echo "Cancelled installation."
    ;;
esac
