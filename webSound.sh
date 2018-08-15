#!/bin/bash
#############################################################
N="demo"			##Default playlist at start
n=$N
Dir=~/.webSound/	##Location of webSound.sh
Local=$Dir"local/"
#clear			##Clear terminal at start
YT=8			##Number of hits from youtube search
editor="nano"
play="mpv --vid=no --really-quiet" #" --load-unsafe-playlists"	##LUP-flag fixes mpv refusing playback of playlist
#play="omxplayer -o local --vol -900"
#############################################################

declare -A c
	c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
	c[by]="\033[1;33m"; c[dy]="\033[2;33m"
	c[r]="\033[31m", c[g]="\033[32m"
	c[b]="\033[34m"; c[bb]="\033[1;34m"
	c[ws]=" w e b s o u n d"; c[lo]=" l o c a l" 
	c[yt]=" y o u t u b e"; c[sc]=" s o u n d c l o u d"
	c[dot]="---------------------------"

declare -A C
	C[initial]="${c[b]}${c[ws]}${c[E]}\n\n"
	C[default]="${c[d]}${c[b]}${c[ws]}${c[E]}\n\n"
	C[youtube]="${c[b]}${c[r]}${c[yt]}${c[E]}\n\n"
	C[soundcloud]="${c[dy]}${c[sc]}${c[E]}\n\n"
	C[Local]="${c[g]}${c[lo]}${c[E]}\n\n"


printf  "${C[initial]}"

help=(" SYNTAX: [First] (Second)"
""
" [h]	→  This help"
""
" [URL]	→  Play [URL]"
" [y]	→  Search youtube"
" [s]	→  Search soundcloud"
" [d]	→  Choose downloaded"
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

	printf "\n|$E\n"$1"\n" >> $Dir$N
	printf "${c[b]} Added:  $E\n    To:  $N ${c[E]}\n"
}

function Ysearch() {
	while true; do clear; printf "${C[youtube]}"
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then echo ' ...'; break
		else
			S="$(echo "$s" | cut -f1- -d" " --output-delimiter="+")"
			w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
			grep "Play now" -A 2 |
			grep "\[" |
			sed 's/[ \t]*//' |
			sed 's/ Duration://' |
			head -n "$YT"

			while true; do read -rep ' n a|d: ' P A

				if [ ! "$P" ]; then break; fi

				link=`w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
					grep "References:" -A 200 |
					grep "\["$P"\]" |
					awk '{print $2}' `

				if [ ! "$A" ]; then
					mpv --vid=no --really-quiet $link

				elif [ "$A" == "a" ]; then
					Add $link

				elif [ "$A" == "d" ]; then
					Download "$link"

				else
					printf " [Number]	→ play choice\n [Number] a	→ add choice\n [empty]	→ exit\n"

				fi
			done
		fi
	done
}

function SCsearch(){
	while true; do clear; printf "${C[soundcloud]}"  # Title
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then echo ' ...'; break
		else
			S=`echo "$s" | cut -f1 -d" " --output-delimiter='%20'`
			w3m -dump -o display_link_number=1 https://soundcloud.com/search?q=$S |
			grep "\[7\]" -A 30 | head -n 20

			while true; do 
				read -rep ' n (a): ' P A

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

				fi
			done
		fi
	done
}

function Download() {
	title=`youtube-dl -e $1 | cut -d" " --output-delimiter="_" -f1-`
	echo " Saving $title to $Local"
	youtube-dl -o $Local$title -f 140 $1 
}


function Local() {
	clear; printf "${C[Local]}"  # Title

	if [ ! $1 ]; then
		select media in `ls $Local`; do
			$play $Local$media; break
		done
	elif [ $1 == "r" ]; then 
		select media in `ls $Local`; do
			rm $Local$media; break
		done
	fi
}


while printf "${c[d]} $N{$(grep '|' -c $Dir$N)}\n${c[dot]}${c[E]}\n"; do

	read -rep "> " U A
	history -s "$U"

	if [ $U ]; then clear; printf "${C[default]}"

		if [ ! $A ]; then

			case $U in
				h)	for i in "${help[@]}"; do 
						printf "\033[1m$i${c[E]}\n"
					done | less -r
					clear; printf "${C[default]}";; 

				y)	Ysearch  ;;

				s)	SCsearch ;;

				d)  Local ;;  # downloaded

				p)	printf "${c[b]} Play: $N: ${c[E]}\n"
					printf "${c[b]}$(grep '|' $Dir$N | cut -d"|" -f1-)${c[E]}\n"
					$play $(grep -v '|' $Dir$N) 2>/dev/null  ;;

				r)	cat $Dir$N 2>/dev/null | less; clear; printf "${C[default]}" ;;

				l)	printf "${c[b]} Playlist	Items\n${c[E]}"
					for i in $(ls $Dir | egrep -iv 'websound|local'); do
						printf " $i		$(grep '|' -c $Dir$i)\n"
					done; echo  ;;

				e)	$editor $Dir$N  ;;

				*)	E=$(youtube-dl --flat-playlist -e $U 2>/dev/null); printf "${c[b]}"
					if [ ! "$E" ]; then echo " Play"; else echo " $E"; fi
					printf "${c[E]}\n"; $play $U 2>/dev/null  ;;
			esac

		elif [ $A ]; then
			case $A in

				p)	if [ ! "$(grep -i $U $Dir$N | grep '|')" ]; then
						printf "${c[b]}$(grep -i $U $Dir$N)${c[E]}\n\n"
						$play $(grep -i $U $Dir$N) 2>/dev/null
					else
						f=(); f+=($(grep -iA 1 $U $Dir$N | egrep -v '\|'))
						printf "${c[b]}$(grep -i $U $Dir$N)${c[E]}\n\n"
						$play ${f[@]} 2>/dev/null
					fi  ;;

				a)	Add "$U"  ;;

				l)	N=$U  ;;

				L)	touch $Dir$U; N=$U
					printf "${c[b]} Created Playlist $U ${c[E]}\n"  ;;

				K)	printf "${c[b]} Remove Playlist $U, with $(grep '|' -c $Dir$U) item(s)?\n"
					printf "${c[dy]}$(cat $Dir$U) ${c[E]}\n" && rm -i $Dir$U  && N=$n ;;

				*)	printf "${c[d]}${c[r]} No proper command given${c[E]}\n"  ;;

			esac
		fi

	else 
		clear; printf "${C[default]}"
	fi
done






