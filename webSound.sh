#!/bin/bash
#############################################################
N=1			##Default playlist at start
Folder=~/.webSound/	##Location of WebSound-folder
#clear 			##Clear terminal at start
play="mpv --vid=no --quiet" #"--load-unsafe-playlists"	##LUP-flag fixes mpv refusing playback of playlist
#play="cvlc some stuff"
#############################################################

declare -A c; c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
c[by]="\033[1;33m"; c[bb]="\033[1;34m"; c[r]="\033[31m"; c[b]="\033[34m"; c[dy]="\033[2;33m"
c[dot]="---------------------------"; c[ws]=" w e b s o u n d"
printf "${c[b]}${c[ws]}${c[E]}\n"

while printf "${c[d]}\n $N{$(grep '#' -c $Folder$N)}\n${c[dot]}${c[E]}\n"; do
	read -rep "> " U A
	history -s "$U"
	if [ $U ]; then clear; printf "${c[d]}${c[ws]}${c[E]}\n\n"; if [ ! $A ]; then case $U in
		p)
		printf "${c[bb]} Starts Playlist $N: ${c[E]}\n\n"
		$play $(grep -v '#' $Folder$N) 2>/dev/null  ;;
		r)
		cat $Folder$N 2>/dev/null || printf "${c[r]} No such playlist${c[E]}\n" ;;
		l)
		printf "${c[bb]} Playlist	Items\n${c[E]}"
		for i in $(ls $Folder | egrep -iv 'websound|help'); do
		printf " $i		$(grep '#' -c $Folder$i)\n"; done  ;;
		e)
		nano $Folder$N  ;;
		*)
		$play $U 2>/dev/null
		esac
	elif [ $A ]; then case $A in
		p)
		f=(); f+=($(egrep -iA 1 $U $Folder$N | egrep -v '#'))
		printf "${c[bb]} Found\n$(grep '#' $Folder$N | grep -i $U)${c[E]}\n\n"
		$play ${f[@]} 2>/dev/null ;;
		a)
		E=$(printf "$(youtube-dl -e $U)\n" | head -n 1)
		printf "\n#$E\n$U\n" >> $Folder$N
		printf "${c[bb]} Added:  $E\n To:  $N ${c[E]}\n${c[E]}"  ;;
		l)
		N=$U ;;
		L)
		touch $Folder$U
		printf "${c[bb]} Created Playlist $U ${c[E]}\n"  ;;
		K)
		printf "${c[bb]} Remove Playlist $U, with $(grep '#' -c $Folder$U) item(s)?\n" && printf "${c[dy]}$(cat $Folder$U) ${c[E]}\n" && rm -i $Folder$U  ;;
		*)
		printf "${c[d]}${c[r]} No proper command given${c[E]}\n"  ;;
		esac
	fi
else printf "> Help <\n"; cat "$Folder"help | less
fi
done
