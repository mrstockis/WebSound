#!/bin/bash
clear

printf "\n\033[1;34m First installation  or  Update ? \n f/u: "
read I

if [[ $I ]]; then if [[ $I == "f" ]]; then
	printf "\n\033[32m -- First Installation --\033[0m\n"
	mkdir ~/.webSound/
	touch ~/.webSound/demo
	## adds three items to playlist 'demo'
	printf "\n|Short Tunes\nhttps://www.youtube.com/watch?v=bBs-lPvk3Zk\n" >> ~/.webSound/demo
	printf "\n|Long Tunes\nhttps://www.youtube.com/watch?v=fWRISvgAygU\n" >> ~/.webSound/demo
	printf "\n|Radio Streams\nhttp://109.123.116.202:8010/stream\n" >> ~/.webSound/demo
	cp webSound.sh ~/.webSound/

	printf "\n Created folder: ~/.webSound/\n"
	echo " and added execute file 'webSound.sh' and default playlist 'demo'"

	printf "\n\033[1;34m Add alias: WebSound  to: ~/.bashrc  ? \n y/N: "
	read A
	if [[ $A == "y" ]]; then
		printf "\nalias WebSound=~/.webSound/./webSound.sh\n" >> ~/.bashrc
		printf "\n\033[1;0m Alias will take effect after next reboot\n"
	else
		printf "\n\033[1;0m Did not add alias\n"
	fi

	printf "\n The script  -and everything else-  is found in: ~/.webSound/\n"
	printf "\n\033[1;32m  Automatically Starts First Run\033[0m\n  Enter "h" for examples on usage\n\n"
	bash ~/.webSound/webSound.sh

elif [[ $I == "u" ]]; then
	printf "\n\033[1;32m -- Update --\033[0m\n"
	cp webSound.sh ~/.webSound/
	printf "\n Updated: webSound.sh\n"
	printf "\n\033[1;34m Done\n\n\033[0m"

else
	printf "\n Input not recognized. Enter 'f' for First intallation, or 'u' for Update.\n\n Exits.. \n\n"
fi
else
	printf "\n No input given. Enter 'f' for First intallation, or 'u' for Update.\n\n Exits.. \n\n"
fi
