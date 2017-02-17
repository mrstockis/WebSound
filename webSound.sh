#!/bin/sh

N=1
Folder=~/.webSound/
H=help

while true; do
printf "\033[2m\n---------------------------------\nEnter 'h' for help .. or \033[22m command: "
read U A

if [ $U -a ! $A ]; then

	if [ $U == "h" ]; then
		echo -e "\e[1;33m\n$(cat $Folder$H)\e[0m"
	elif [ $U == "p" ]; then
		echo -e "\e[1;34m  Starts Playlist $N: \e[0m\n"
		mpv --vid=no --quiet $(cat $Folder$N | grep -v '#')
	elif [ $U == "r" ]; then
		(echo -e "\e[1;34m Playlist $N, $(cat $Folder$N | grep '#' -c) item(s)\e[0m" && cat $Folder$N | less) || echo -e "\e[31m No such playlist\e[0m"
	elif [ $U == "R" ]; then
		echo -e "\e[1;34m$(ls $Folder | egrep -iv 'websound|help')\n"
		echo -e " Playlist $N, $(cat $Folder$N | grep '#' -c) item(s)\e[0m"
	elif [ $U == "e" ]; then
		nano $Folder$N
	else
		mpv --vid=no --quiet $U
	fi

elif [ $U -a $A == "f" ]; then
	echo -e "\e[1;34m Found\n $(cat $Folder$N | grep -i $U)\e[0m\n"
	mpv --vid=no --quiet $(cat $Folder$N | grep -i $U)
elif [ $U -a $A == "a" ]; then
	printf '\n#\n' >> $Folder$N && echo $U >> $Folder$N
	echo -e "\e[1;34m Added $URL to Playlist $N \e[0m"
elif [ $U -a $A == "p" ]; then
	N=$U
	(echo -e "\e[1;34m Playlist $N, $(cat $Folder$N | grep '#' -c) item(s)\e[0m") || echo -e "\e[31m No such playlist\e[0m"
elif [ $U -a $A == "P" ]; then
	touch $Folder$U
	echo -e "\e[1;34m Created Playlist $U \e[0m"
elif [ $U -a $A == "C" ]; then
	(echo -e "\e[1;34m Remove Playlist $U, with $(cat $Folder$U | grep '#' -c) item(s)?" && echo -e "\e[2;33m$(cat $Folder$U) \e[0m" && rm -i $Folder$U) || echo -e "\e[31m No such playlist found\e[0m"
else
	echo -e '\e[31m No proper command given\e[0m'
fi

done
