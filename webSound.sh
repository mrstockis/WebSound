#!/bin/bash
#############################################################
N=1			##Default playlist at start
Folder=~/.webSound/	##Location of WebSound-folder
#clear 			##Clear terminal at start
play="mpv --vid=no --quiet" #"--load-unsafe-playlists"	#LUP-flag fixes soundcloud refusing playback of playlist
#play="cvlc some stuff"
#############################################################

#Array of color#
declare -A c; c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
c[by]="\033[1;33m"; c[bb]="\033[1;34m"; c[r]="\033[31m"; c[b]="\033[34m"; c[dy]="\033[2;33m"
c[dot]="----------------------------------"
printf "\n${c[b]}          WebSound${c[E]}"
while true; do
printf "${c[d]}\n  Playlist $N: $(grep '#' -c $Folder$N) item(s)\n${c[dot]}\nEnter 'h' for help .. or ${c[D]} command: "
read U A

if [ $U ]; then clear; printf "${c[d]}${c[dot]}${c[E]}\n\n"; if [ ! $A ]; then case $U in
		h)
		cat "$Folder"help | less ;;
		p)
		printf "${c[bb]}  Starts Playlist $N: ${c[E]}\n\n"
		$play $(grep -v '#' $Folder$N) 2>/dev/null  ;;
		r)
		cat $Folder$N 2>/dev/null || printf "${c[r]} No such playlist${c[E]}\n"  ;;
		R)
		printf "${c[bb]} Playlist	Items\n${c[E]}"
		for i in $(ls $Folder | egrep -iv 'websound|help'); do
		printf " $i		$(grep '#' -c $Folder$i)\n"; done  ;;
		e)
		nano $Folder$N  ;;
		*)
		$play $U 2>/dev/null
	esac
  elif [ $A ]; then case $A in
	f)
	printf "${c[bb]} Found\n$(egrep -iv '#' $Folder$N | grep -i $U)${c[E]}\n\n"
	$play $(egrep -iv '#' $Folder$N | grep -i $U) 2>/dev/null  ;;
	a)
	E=$(printf "$(youtube-dl -e $U)\n" | head -n 1)
	printf "\n#$E\n$U\n" >> $Folder$N
	printf "${c[bb]} Added:  $E\n To:  $N ${c[E]}\n${c[E]}"  ;;
	p)
	N=$U ;;
	P)
	touch $Folder$U
	printf "${c[bb]} Created Playlist $U ${c[E]}\n"  ;;
	K)
	printf "${c[bb]} Remove Playlist $U, with $(grep '#' -c $Folder$U) item(s)?\n" && printf "${c[dy]}$(cat $Folder$U) ${c[E]}\n" && rm -i $Folder$U  ;;
	*)
	clear; printf "${c[d]}${c[dot]}\n${c[r]}\n No proper command given${c[E]}\n"  ;;
	esac
  fi
else 	clear; printf "${c[d]}${c[dot]}\n${c[r]}\n No proper command given${c[E]}\n"
fi
done
