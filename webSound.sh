#!/bin/bash

N=1
Folder=~/.webSound/
H=help
#clear

printf "\n\033[34m          WebSound\033[0m"
while true; do
printf "\033[2m\n----------------------------------\nEnter 'h' for help .. or \033[22m command: "
read U A

if [ $U ]; then if [ ! $A ]; then

	if [ $U == "h" ]; then
		printf "\e[1;33m\n$(cat $Folder$H)\e[0m\n"
	elif [ $U == "p" ]; then
		printf "\e[1;34m  Starts Playlist $N: \e[0m\n\n"
		mpv --vid=no --quiet $(cat $Folder$N | grep -v '#')
	elif [ $U == "r" ]; then
		(printf "\e[1;34m Playlist $N, $(cat $Folder$N | grep '#' -c) item(s)\e[0m\n" && cat $Folder$N | less) || printf "\e[31m No such playlist\e[0m\n"
	elif [ $U == "R" ]; then
		printf "\e[1;34m$(ls $Folder | egrep -iv 'websound|help')\n\n"
		printf " Playlist $N, $(cat $Folder$N | grep '#' -c) item(s)\e[0m\n"
	elif [ $U == "e" ]; then
		nano $Folder$N
	else
		mpv --vid=no --quiet $U
	fi

  elif [ $A == "f" ]; then
	printf "\e[1;34m Found\n $(cat $Folder$N | grep -i $U)\e[0m\n\n"
	mpv --vid=no --quiet $(cat $Folder$N | grep -i $U)
  elif [ $A == "a" ]; then
	printf '\n#\n' >> $Folder$N && echo $U >> $Folder$N
	printf "\e[1;34m Added $URL to Playlist $N \e[0m\n"
  elif [ $A == "p" ]; then
	N=$U; (printf "\e[1;34m Playlist $N, $(cat $Folder$N | grep '#' -c) item(s)\e[0m\n") || printf "\e[31m No such playlist\e[0m\n"
  elif [ $A == "P" ]; then
	touch $Folder$U
	printf "\e[1;34m Created Playlist $U \e[0m\n"
  elif [ $A == "C" ]; then
	(printf "\e[1;34m Remove Playlist $U, with $(cat $Folder$U | grep '#' -c) item(s)\n?" && printf "\e[2;33m$(cat $Folder$U) \e[0m\n" && rm -i $Folder$U) || printf "\e[31m No such playlist found\e[0m\n"
  fi

else 	printf '\e[31m No proper command given\e[0m\n'

fi
done
