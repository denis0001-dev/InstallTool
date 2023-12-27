#!/bin/bash
sudo gpasswd -a $USER plugdev
case $(lsb_release -i -s) in
  "Ubuntu")
    sudo add-apt-repository ppa:openrazer/stable
    sudo apt update
    sudo apt install -y openrazer-meta
    sudo add-apt-repository ppa:polychromatic/stable
    sudo apt update
    sudo apt install -y polychromatic
    ;;
  "Debian")
    sudo apt update
    sudo apt install -y openrazer-meta
    echo "deb [signed-by=/usr/share/keyrings/polychromatic.gpg] http://ppa.launchpad.net/polychromatic/stable/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/polychromatic.list
    curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xc0d54c34d00160459588000e96b9cd7c22e2c8c5' | sudo gpg --dearmour -o /usr/share/keyrings/polychromatic.gpg
    sudo apt-get update
    sudo apt install -y polychromatic
    ;;
  *)
    echo "Error: this distributition is not supported!"
    exit 1
    ;;
esac
