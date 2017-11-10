#!/bin/bash

PORT=25565
URL="https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/minecraft_server.1.12.2.jar"
MAX="512M"
MIN="512M"
DEB="deb http://ftp.us.debian.org/debian/ jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
deb http://ftp.us.debian.org/debian/ jessie-updates main contrib non-free
deb http://ftp.us.debian.org/debian/ jessie-backports main contrib non-free"

while [ "$#" -gt 0 ] ; do 
    case $1 in
        -p)
            shift
            PORT="$1"
            ;;
        -max)
            shift
            MAX="$1"
            ;;
        -min)
            shift
            MIN="$1"
            ;;
        *)
            shift
            echo "No arguments passed"
            ;;
    esac
done
echo $PORT

# Add backport dependencies for openjdk-8-jre
if [ -f /etc/apt/openjdk8.list ] ; then
    echo "JDK 8 Installed"
else
    sudo touch /etc/apt/openjdk8.list  
    sudo chmod 755 /etc/apt/openjdk8.list 
    echo $DEB >> /etc/apt/openjdk8.list
    sudo apt update
fi

# Install Java if it doesn't already exist on this machine
sudo apt -y install openjdk-8-jre-headless
if [ -f minecraft_server*.jar ] ; then 
    echo "skipping download"
else
    wget $URL
fi

# If the eula.txt already exists then skip intial setup
if [ -f eula.txt ] ; then 
    echo "Dont run initial java setup"
else
    # We expect this command to exit and create a series of files
    java -Xmx$MAX -Xms$MIN -jar minecraft_server*.jar nogui
fi

# Allow connections on the port
sudo ufw allow $PORT
sed -i "s/eula=false/eula=true/" ./eula.txt
java -Xmx$MAX -Xms$MIN -jar minecraft_server*.jar nogui

