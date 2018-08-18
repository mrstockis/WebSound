#!/bin/bash
#############################################################
#clear			##Clear terminal at start
N="demo"			##Default playlist at start
n=$N
Dir=~/.webSound/	##Location of webSound.sh
Local=$Dir"local/"
Nhits=8			##Number of hits from youtube search
editor="nano"
player="mpv --vid=no --really-quiet" # --load-unsafe-playlists"	##LUP-flag fixes mpv refusing playback of playlist
#play="omxplayer -o local --vol -900"
#############################################################


# "\033[ brightness ; colortext ; colorbackground m" :: (0,1,2) ; 30+(0→9) ; 40+(0→9)
# \033[1;32;44m  :: bright green text, on blue background
# \033[0m        :: return to white text on transparent background

declare -A c
	c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
	c[by]="\033[1;33m"; c[dy]="\033[2;33m"
	c[r]="\033[31m", c[g]="\033[32m"
	c[b]="\033[34m"; c[bb]="\033[1;34m"
	c[Er]="\033[1;39;41m"
	c[ws]=" w e b s o u n d"; c[lo]=" l o c a l" 
	c[yt]=" y o u t u b e"; c[sc]=" s o u n d c l o u d"
	c[bad]=" No proper command. Enter 'h' for help"
	c[dot]="---------------------------"

declare -A C
	C[initial]="${c[b]}${c[ws]}${c[E]}\n\n"
	C[default]="${c[d]}${c[b]}${c[ws]}${c[E]}\n\n"
	C[youtube]="${c[b]}${c[r]}${c[yt]}${c[E]}\n\n"
	C[soundcloud]="${c[dy]}${c[sc]}${c[E]}\n\n"
	C[Local]="${c[g]}${c[lo]}${c[E]}\n\n"
	C[nProp]="${c[Er]}${c[bad]}${c[E]}\n\n"

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


function YTsearch() {
	while true; do clean "${C[youtube]}"
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then Top; break
		else
			S="$(echo "$s" | cut -f1- -d" " --output-delimiter="+")"
			w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
			grep "Play now" -A 2 |
			grep "\[" |
			sed 's/[ \t]*//' |
			sed 's/ Duration://' |
			head -n "$Nhits"

			while true; do read -rep ' n (a|d): ' P A

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
					printf " [Number]	→ play choice\n [Number] (a|d)	→ add/download choice\n [empty]	→ back to search\n"

				fi
			done
		fi
	done
}


function SCsearch(){
	while true; do clean "${C[soundcloud]}"  # Title
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then Top; break
		else
			S=`echo "$s" | cut -f1 -d" " --output-delimiter="%20" `
			w3m -dump -o display_link_number=1 https://soundcloud.com/search?q=$S |
			grep "\[7\]" -A 30 |
			sed 's/[ \t• ]*//' |
			grep "\]" |
			head -n 10

			while true; do read -rep ' n (a|d): ' P A

				if [ ! "$P" ]; then break; fi
					
				link=`w3m -dump -o display_link_number=1 https://soundcloud.com/search?q="$S" |
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
					printf " [Number]	→ play choice\n [Number] (a|d)	→ add/download choice\n [empty]	→ back to search\n"

				fi
			done
		fi
	done
}


function Download() {
	title=`youtube-dl -e $1 | cut -d" " --output-delimiter="_" -f1-`
	echo " Saving $title to $Local"
	youtube-dl -o $Local$title -f bestaudio $1 
}


function Select() {
	declare -A items
	count=1
	for i in `ls $Local`; do
		echo "$count: $i"
		items[$count]="$i"
		count=$((count+1))
	done
	echo
	while true; do
		read -rep " n (r): " U A
		if [ -z "$U" ]; then Top; break
		elif [ -z "$A" ]; then $player $Local${items[$U]}
		else
			if [ "$A" == "r" ]; then rm $Local${items[$U]}
			else printf "\n${C[nProp]}"; fi
		fi
	done
}


function Local() {
	clean "${C[Local]}"
	Select 
	Top
}


function Info() {
	printf "${c[d]} $N{$(grep '|' -c $Dir$N)}\n${c[dot]}${c[E]}\n"
}


function clean() {
	clear; printf "$1"
}


function Top() {
	clean "${C[default]}"
}


printf "${C[initial]}"

## Main loop
while true; do Info

	read -rep "> " U A
	history -s "$U"

	if [ $U ]; then Top

		if [ ! $A ]; then

			case $U in
				h)	for i in "${help[@]}"; do printf "\033[1m$i${c[E]}\n"
					done | less -r ; Top ;; 

				y)	YTsearch  ;;

				s)	SCsearch ;;

				d)  Local ;;  # downloaded

				p)	printf "${c[b]} Play: $N: ${c[E]}\n"
					printf "${c[b]}$(grep '|' $Dir$N | cut -d"|" -f1-)${c[E]}\n"
					$player $(grep -v '|' $Dir$N) 2>/dev/null  ;;

				r)	cat $Dir$N 2>/dev/null | less; Top ;;

				l)	printf "${c[b]} Playlist	Items\n${c[E]}"
					for i in $(ls $Dir | egrep -iv 'websound|local'); do
						printf " $i		$(grep '|' -c $Dir$i)\n"
					done; echo  ;;

				e)	$editor $Dir$N  ;;

				*)	if (echo $U | grep /); then
						E=$(youtube-dl --flat-playlist -e $U 2>/dev/null); printf "${c[b]}"
						printf " Play:"; echo " $E"
						printf "${c[E]}\n"; $player $U 2>/dev/null
					else printf "${C[nProp]}"; fi  ;;
			esac

		elif [ $A ]; then
			case $A in

				p)	if [ ! "$(grep -i $U $Dir$N | grep '|')" ]; then
						printf "${c[b]}$(grep -i $U $Dir$N)${c[E]}\n\n"
						$player $(grep -i $U $Dir$N) 2>/dev/null
					else
						f=(); f+=($(grep -iA 1 $U $Dir$N | egrep -v '\|'))
						printf "${c[b]}$(grep -i $U $Dir$N)${c[E]}\n\n"
						$player ${f[@]} 2>/dev/null
					fi  ;;

				a)	Add "$U"  ;;

				l)	N=$U  ;;

				L)	touch $Dir$U; N=$U
					printf "${c[b]} Created Playlist $U ${c[E]}\n"  ;;

				K)	printf "${c[b]} Remove Playlist $U, with $(grep '|' -c $Dir$U) item(s)?\n"
					printf "${c[dy]}$(cat $Dir$U) ${c[E]}\n" && rm -i $Dir$U  && N=$n ;;

				*)	printf "${C[nProp]}"  ;;

			esac
		fi

	else 
		Top
	fi
done


