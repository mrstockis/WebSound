#!/bin/sh
clear

mkdir ~/.webSound/
echo -e "\n Created folder '~/.webSound'"

touch ~/.webSound/1
echo " Added default playlist, called '1'"

#adds three items to playlist 1
echo -e "#Soundcloud\nhttps://soundcloud.com/themidnightofficial/vampires\n" >> ~/.webSound/1
echo -e "#Youtube\nhttps://www.youtube.com/watch?v=fWRISvgAygU\n" >> ~/.webSound/1
echo -e "#Radio\nhttp://109.123.116.202:8010/stream\n" >> ~/.webSound/1

chmod +x webSound.sh
cp webSound.sh ~/.webSound/webSound.sh
echo " Copied 'webSound.sh'"
cp help ~/.webSound/help
echo " Copied 'help'"
echo -e "\n Done, you can now delete this whole folder\n"
echo -e "\e[1;33m Script 'webSound.sh' is found in '~/.webSound/'\n\e[0m"
echo -e "\e[1;34m  Automaticly Starts First Run\e[0m"
~/.webSound/./webSound.sh
