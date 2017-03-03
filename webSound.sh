#!/bin/bash
#############################################################
N=1			##Default playlist at start
Folder=~/.webSound/	##Location of WebSound-folder (if need to move folder)
#clear 			##Clear terminal at start

###Player - mpv|cvlc|omxplayer
play="mpv --vid=no --quiet"
#play="cvlc something something"
#play="sudo omxplayer -o hdmi -b \$(youtube-dl -gf bestaudio"
#############################################################

#Array of color#
declare -A c; c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
c[by]="\033[1;33m"; c[bb]="\033[1;34m"; c[r]="\033[31m"; c[b]="\033[34m"; c[dy]="\033[2;33m"

printf "\n${c[b]}          WebSound${c[E]}"
while true; do
printf "${c[d]}\n----------------------------------\nEnter 'h' for help .. or ${c[D]} command: "
read U A

if [ $U ]; then if [ ! $A ]; then

	if [ $U == "h" ]; then
		printf "${c[by]}\n$(cat "$Folder"help)${c[E]}\n"
	elif [ $U == "p" ]; then
		printf "${c[bb]}  Starts Playlist $N: ${c[E]}\n\n"
		$play $(grep -v '#' $Folder$N)
	elif [ $U == "r" ]; then
		(printf "${c[bb]} Playlist $N, $(grep '#' -c $Folder$N) item(s)${c[E]}\n" && cat $Folder$N) || printf "${c[r]} No such playlist${c[E]}\n"
	elif [ $U == "R" ]; then
		printf "${c[bb]}$(ls $Folder | egrep -iv 'websound|help')\n\n"
		printf " Playlist $N, $(grep '#' -c $Folder$N) item(s)${c[E]}\n"
	elif [ $U == "e" ]; then
		nano $Folder$N
	else
		$play $U
	fi

  elif [ $A == "f" ]; then
	printf "${c[bb]} Found\n $(grep -i $U $Folder$N)${c[E]}\n\n"
	$play $(grep -i $U $Folder$N)
  elif [ $A == "a" ]; then
	printf '\n#\n' >> $Folder$N && echo $U >> $Folder$N
	printf "${c[bb]} Added $URL to Playlist $N ${c[E]}\n"
  elif [ $A == "p" ]; then
	N=$U; (printf "${c[bb]} Playlist $N, $(grep '#' -c $Folder$N) item(s)${c[E]}\n") || printf "${c[r]} No such playlist${c[E]}\n"
  elif [ $A == "P" ]; then
	touch $Folder$U
	printf "${c[bb]} Created Playlist $U ${c[E]}\n"
  elif [ $A == "C" ]; then
	(printf "${c[bb]} Remove Playlist $U, with $(grep '#' -c $Folder$U) item(s)?\n" && printf "${c[dy]}$(cat $Folder$U) ${c[E]}\n" && rm -i $Folder$U) || printf "${c[r]} No such playlist found${c[E]}\n"
  fi

else 	printf '${c[r]} No proper command given${c[E]}\n'

fi
done
