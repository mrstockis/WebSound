#!/bin/bash

clear

printf "\n\033[1;34m First installation  or  Update ? \n f/u: "
read I

if [[ $I ]]; then if [[ $I == "f" ]]; then
	printf "\n\033[32m -- First Installation --\033[0m\n"
	mkdir ~/.webSound/
	mkdir ~/.webSound/local
	touch ~/.webSound/demo
	## adds three items to playlist 'demo'
	printf "\n|Short Tunes\nhttps://www.youtube.com/watch?v=bBs-lPvk3Zk\n" >> ~/.webSound/demo
	printf "\n|Long Tunes\nhttps://www.youtube.com/watch?v=fWRISvgAygU\n" >> ~/.webSound/demo
	printf "\n|Radio Streams\nhttp://109.123.116.202:8010/stream\n" >> ~/.webSound/demo
	cp webSound.sh ~/.webSound/
  cp functs/ ~/.webSound/

	printf "\n\033[1;34m Add alias: WebSound  to: ~/.bashrc  ? \n y/N: "
	read A
	if [[ $A == "y" ]]; then
		printf "\nalias WebSound=~/.webSound/./webSound.sh\n" >> ~/.bashrc
		printf "\n\033[1;0m Alias will take effect after next reboot\n"
	else
		printf "\n\033[1;0m Did not add alias\n"
	fi

	printf "\n\033[1m The script  -and everything else-  is found in: ~/.webSound/\n"
  printf " Enter 'h' for help section\n\n"
  read -p ' Press Enter ..'
	printf "\n\033[32m  Starts WebSound, this will clear the terminal\033[0m\n"
  read -p ' Start y/N? ' A
  [[ $A -eq "y" ]] && bash ~/.webSound/webSound.sh || exit

elif [[ $I == "u" ]]; then
	printf "\n\033[1;32m -- Update --\033[0m\n"
	cp webSound.sh ~/.webSound/
  cp functs/ ~/.webSound/

	printf "\n Updated: webSound.sh\n"
	printf "\n\033[1;34m Done\n\n\033[0m"

else
	printf "\n Input not recognized. Enter 'f' for First intallation, or 'u' for Update.\n\n Exits.. \n\n"
fi
else
	printf "\n No input given. Enter 'f' for First intallation, or 'u' for Update.\n\n Exits.. \n\n"
fi
