#!/bin/bash
clear
printf "\n\033[1m First installation  or  Update ? \n f/u: "
read I
if [[ $I ]]; then if [[ $I == "f" ]]; then
printf "\n\033[32m -- First Installation --\033[0m\n"
mkdir ~/.webSound/
printf "\n Created folder: ~/.webSound/\n"
touch ~/.webSound/1
echo " Added default playlist: 1"

## adds three items to playlist 1
printf "\n#Soundcloud\nhttps://soundcloud.com/themidnightofficial/vampires\n" >> ~/.webSound/1
printf "\n#Youtube\nhttps://www.youtube.com/watch?v=fWRISvgAygU\n" >> ~/.webSound/1
printf "\n#Radio\nhttp://109.123.116.202:8010/stream\n" >> ~/.webSound/1

cp webSound.sh ~/.webSound/
echo " Copied: webSound.sh"
cp help ~/.webSound/
echo " Copied: help"
printf "\n\033[1;33m Add alias: WebSound  to: ~/.bashrc  ? \n y/N: "
read A
if [[ $A == "y" ]]; then
printf "\nalias WebSound=~/.webSound/./webSound.sh\n" >> ~/.bashrc
printf "\033[1;33m Alias will take effect after next reboot\n"
else
printf " Did not add alias\n"
fi
printf "\n Script: webSound.sh  -and everything else-  is found in: ~/.webSound/\033[0m\n"
printf "\n Done, you can now delete This folder\n"
printf "\n\033[1;34m  Automatically Starts First Run\033[0m\n"
bash ~/.webSound/webSound.sh

elif [[ $I == "u" ]]; then
printf "\n\033[1;34m -- Update --\033[0m\n"
cp webSound.sh ~/.webSound/
printf "\n Updated: webSound.sh\n"
cp help ~/.webSound/
printf " Updated: help\n"
printf "\n Done\n\n"

else
printf "\n Input not recognized. Enter 'f' for First intallation, or 'u' for Update.\n\n Exits.. \n\n"
fi
else
printf "\n No input given. Enter 'f' for First intallation, or 'u' for Update.\n\n Exits.. \n\n"
fi
