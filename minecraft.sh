#!/bin/bash

PORT=25565
URL="https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/minecraft_server.1.12.2.jar"
MAX="512M"
MIN="512M"
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

sudo apt -y install openjdk-8-jre-headless
if [ -f minecraft_server*.jar ] ; then 
    echo "skipping download"
else
    wget $URL
fi

if [ -f eula.txt ] ; then 
    echo "Dont run initial java setup"
else
    # We expect this command to exit and create a series of files
    java -Xmx$MAX -Xms$MIN -jar minecraft_server*.jar nogui
fi

sudo ufw allow $PORT
sed -i "s/eula=false/eula=true/" ./eula.txt
java -Xmx$MAX -Xms$MIN -jar minecraft_server*.jar nogui

