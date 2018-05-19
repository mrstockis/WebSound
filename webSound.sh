#!/bin/bash
#############################################################
N="demo"			##Default playlist at start
n=$N
Folder=~/.webSound/	##Location of webSound.sh
#clear			##Clear terminal at start
YT=8			##Number of hits from youtube search
editor="nano"
play="mpv --vid=no --really-quiet" #" --load-unsafe-playlists"	##LUP-flag fixes mpv refusing playback of playlist
#play="cvlc some stuff"
#############################################################

declare -A c; c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
	c[by]="\033[1;33m"; c[bb]="\033[1;34m"; c[r]="\033[31m"; c[b]="\033[34m"; c[dy]="\033[2;33m"
	c[ws]=" w e b s o u n d"; c[yt]=" y o u t u b e"; c[sc]=" s o u n d c l o u d"
	c[dot]="---------------------------"

printf "${c[b]}${c[ws]}${c[E]}\n"

help=(" SYNTAX: [First] (Second)"
""
" [h]	→  This help"
""
" [URL]	→  Play [URL]"
" [y]	→  Search youtube"
" [s]	→  Search soundcloud"
" [p]	→  Play through active playlist"
" [r]	→  Read current playlist"
" [l]	→  List all playlists"
" [e]	→  Edit playlist"
""
" [URL] (a)	  → (a)dd [URL] to current playlist"
" [SearchTerm] (p) → (p)lay [SearchTerm] from playlist"
" [ListName] (l)	→  choose playlist [ListName]"
" [ListName] (L)	→  create playlist [ListName]"
" [ListName] (K)	→  delete playlist [ListName]"
""
" <q> exits active media <ctrl+c> stops script"
""
" Some preferences(player,editor,etc.) can be made "
" by editing top-section of the script '.webSound.sh'")

function Add() {
	E=$(printf "$(youtube-dl --flat-playlist -e "$1")\n" | head -n 1)

	if [ ! "$E" ]; then E="Playlist?"; fi

	printf "\n|$E\n"$1"\n" >> $Folder$N
	printf "${c[b]} Added:  $E\n    To:  $N ${c[E]}\n"
}

function Ysearch() {
	while true; do clear; printf "${c[b]}${c[r]}${c[yt]}${c[E]}\n\n"
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then echo ' ...'; break
		else
			S="$(echo "$s" | cut -f1- -d" " --output-delimiter="+")"
			w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
			grep "Play now" -A 2 |
			grep "\[" |
			sed 's/[ \t]*//' |
			head -n "$YT"

		while true; do read -rep ' Play or add: ' P A

			if [ ! "$P" ]; then break

			elif [ ! "$A" ]; then
				mpv --vid=no --really-quiet $(
				w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
				grep "References:" -A 200 |
				grep "\["$P"\]" |
				awk '{print $2}')

			elif [ "$A" == "a" ]; then
				Add "$(w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
				grep "References:" -A 200 |
				grep "\["$P"\]" |
				awk '{print $2}')"

			else
				printf " [Number]	→ play choice\n [Number] a	→ add choice\n [empty]	→ exit\n"

			fi; done; fi; done
}

function SCsearch(){
	while true; do clear; printf "${c[dy]}${c[sc]}${c[E]}\n\n"
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then echo ' ...'; break
		else
			S=`echo "$s" | cut -f1 -d" " --output-delimiter='%20'`
			w3m -dump -o display_link_number=1 https://soundcloud.com/search?q=$S |
			grep "\[7\]" -A 30 | head -n 20

		while true; do read -rep ' Play or add: ' P A

			if [ ! "$P" ]; then break

			elif [ ! "$A" ]; then
				mpv --vid=no --really-quiet `
				w3m -dump -o display_link_number=1 https://soundcloud.com/search?q="$S" |
				grep "References:" -A 200 |
				grep "\["$P"\]" |
				awk '{print $2}'`

			elif [ "$A" == "a" ]; then
				Add `w3m -dump -o display_link_number=1 https://soundcloud.com/search?q="$S" |
				grep "References:" -A 200 |
				grep "\["$P"\]" |
				awk '{print $2}'`

			else
				printf " [Number]	→ play choice\n [Number] a	→ add choice\n [empty]	→ exit\n"

			fi; done; fi; done
}


while printf "${c[d]}\n $N{$(grep '|' -c $Folder$N)}\n${c[dot]}${c[E]}\n"; do

	read -rep "> " U A
	history -s "$U"

	if [ $U ]; then clear; printf "${c[d]}${c[b]}${c[ws]}${c[E]}\n\n"

		if [ ! $A ]; then

			case $U in
				h)	for i in "${help[@]}"; do printf "\033[1m$i${c[E]}\n"; done | less -r; clear; printf "${c[d]}${c[b]}${c[ws]}${c[E]}\n";; 

				y)	Ysearch  ;;

				s)	SCsearch ;;

				p)	printf "${c[b]} Play: $N: ${c[E]}\n"
					printf "${c[b]}$(grep '|' $Folder$N | cut -d"|" -f1-)${c[E]}\n"
					$play $(grep -v '|' $Folder$N) 2>/dev/null  ;;

				r)	cat $Folder$N 2>/dev/null | less; clear; printf "${c[d]}${c[b]}${c[ws]}${c[E]}\n" ;;

				l)	printf "${c[b]} Playlist	Items\n${c[E]}"
					for i in $(ls $Folder | egrep -iv 'websound|help'); do
						printf " $i		$(grep '|' -c $Folder$i)\n"
					done  ;;

				e)	$editor $Folder$N  ;;

				*)	E=$(youtube-dl --flat-playlist -e $U 2>/dev/null); printf "${c[b]}"
					if [ ! "$E" ]; then echo " Play"; else echo " $E"; fi
					printf "${c[E]}\n"; $play $U 2>/dev/null  ;;
			esac

	elif [ $A ]; then case $A in

		p)	if [ ! "$(grep -i $U $Folder$N | grep '|')" ]; then
				printf "${c[b]}$(grep -i $U $Folder$N)${c[E]}\n\n"
				$play $(grep -i $U $Folder$N) 2>/dev/null
			else
				f=(); f+=($(grep -iA 1 $U $Folder$N | egrep -v '\|'))
				printf "${c[b]}$(grep -i $U $Folder$N)${c[E]}\n\n"
				$play ${f[@]} 2>/dev/null
			fi  ;;

		a)	Add "$U"  ;;

		l)	N=$U  ;;

		L)	touch $Folder$U; N=$U
			printf "${c[b]} Created Playlist $U ${c[E]}\n"  ;;

		K)	printf "${c[b]} Remove Playlist $U, with $(grep '|' -c $Folder$U) item(s)?\n"
			printf "${c[dy]}$(cat $Folder$U) ${c[E]}\n" && rm -i $Folder$U  && N=$n ;;

		*)	printf "${c[d]}${c[r]} No proper command given${c[E]}\n"  ;;

	esac; fi

else clear; printf "${c[d]}${c[b]}${c[ws]}${c[E]}\n"
fi; done



