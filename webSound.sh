#!/bin/bash
#############################################################
#clear				##Clear terminal at start
N="demo"			##Default playlist at start
n=$N
Dir=~/.webSound/	##Location of webSound.sh
Local=$Dir"local/"
Nhits=12			##Number of hits from youtube search
editor="nano -SL"
player="mpv --vid=no --really-quiet "#"--load-unsafe-playlists"	##LUP-flag fixes mpv refusing playback of playlist
#player="omxplayer -o local --vol -900"
#############################################################


# \033[ brightness ; colortext ; colorbackground m :: (0,1,2) ; 30+(0→9) ; 40+(0→9)
# \033[1;32;44m  :: bright green text, on blue background
# \033[0m        :: return to white text on transparent background

declare -A c
	c[B]="\033[1m"; c[D]="\033[2m"; c[E]="\033[0m"
	c[y]="\033[33m"; c[r]="\033[31m";
	c[g]="\033[32m"; c[b]="\033[34m"
	c[Er]="\033[1;39;41m"
	c[ws]=" w e b s o u n d"; c[lo]=" l o c a l"
	c[yt]=" y o u t u b e"; c[sc]=" s o u n d c l o u d"
	c[bad]=" No proper command. Enter 'h' for help"
	c[dot]="---------------------------"

declare -A C
	C[initial]="${c[B]}${c[b]}${c[ws]}${c[E]}\n\n"
	C[default]="${c[b]}${c[ws]}${c[E]}\n\n"
	C[youtube]="${c[B]}${c[r]}${c[yt]}${c[E]}\n\n"
	C[soundcloud]="${c[y]}${c[sc]}${c[E]}\n\n"
	C[Local]="${c[g]}${c[lo]}${c[E]}\n\n"
	C[saving]="${c[b]}Saving${c[E]}"
	C[to]="${c[b]}to${c[E]}"
	C[state0]="${C[B]}${c[y]}state${c[E]}"
	C[state1]="\b\b\b\b\b${c[g]}state${c[E]}\n"
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


function Top() {
	clean "${C[default]}"
}
function Info() {
	printf "${c[d]} $N{`grep '|' -c $Dir$N`}\n${c[dot]}${c[E]}\n"
}
function clean() {
	clear; printf "$1"
}


function Add() {
	E=`printf "$(youtube-dl --flat-playlist -e "$1")\n" | head -n 1`

	if [ ! "$E" ]; then E="Playlist?"; fi

	printf "\n|$E\n"$1"\n" >> $Dir$N
	printf " ${c[b]}Added:${c[E]}  $E\n    ${c[b]}To:${c[E]}  $N\n"
}


function Download() {
	title=`youtube-dl -e $1 | sed 's/\ /_/g'`
	printf " ${C[saving]} $title ${C[to]} $Local ... "
	state 0
	youtube-dl -qo $Local$title -f bestaudio $1
	state 1
}


function state() {
	if [ $1 == 0 ]; then
		state="${C[state0]}"
	else
		state="${C[state1]}"
	fi
	printf $state
}

function YTsearch() {
	while true; do clean "${C[youtube]}"
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then Top; break
		else
			S="`echo "$s" | sed 's/\ /+/g'`"
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
					$player $link

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
	main
}


function SCsearch(){
	while true; do clean "${C[soundcloud]}"  # Title
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then Top; break
		else
			S=`echo "$s" | sed 's/\ /+/g'`
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
					$player $link

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


function Local() {
	clean "${C[Local]}"
	Select
	Top; main
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
		if [ -z "$U" ]; then
			break
		elif [ -z "$A" ]; then
			$player $Local${items[$U]}
			Local
		else
			if [ "$A" == "r" ]; then
				rm $Local${items[$U]}
				Local
			else
				printf "\n${C[nProp]}"; fi
		fi
	done
}


function playAll() {
	printf "${c[b]} @$N ${c[E]}\n"
	printf "${c[b]}`grep '|' $Dir$N | cut -d"|" -f1-`${c[E]}\n"
	$player `grep -v '|' $Dir$N` 2>/dev/null
}


function playSpecific() {
	if [ ! "`grep -i $1 $Dir$N | grep '|'`" ]; then
		printf "${c[b]}`grep -i $1 $Dir$N`${c[E]}\n\n"
		$player `grep -i $1 $Dir$N` 2>/dev/null
	else
		f=(); f+=(`grep -iA 1 $1 $Dir$N | egrep -v '\|'`)
		printf "${c[b]}`grep -i $1 $Dir$N`${c[E]}\n\n"
		$player ${f[@]} 2>/dev/null
	fi
}


function playLink() {
	if (echo $1 | grep /); then
		echo "Grabbing content.."
		E=`youtube-dl --flat-playlist -e $1 2>/dev/null`
		Top
		printf "${c[b]} $E ${c[E]}\n"
		$player $1 2>/dev/null
	else
		printf "${C[nProp]}"
	fi
}


function createList() {
	touch $Dir$1; N=$1
	printf "${c[b]} Created Playlist $1 ${c[E]}\n"
}


function listLists() {
	printf "${c[b]} Playlist	Items\n${c[E]}"
	for i in `ls $Dir | egrep -iv 'websound|local'`; do
		printf " $i		`grep '|' -c $Dir$i`\n"
	done; echo
}


function readList() {
	cat $Dir$N 2>/dev/null | less
	Top
}


function removeList() {
	printf "${c[b]} Removes playlist $1, with `grep '|' -c $Dir$1` item(s)\n"
	printf "${c[dy]}`cat $Dir$1 | grep '|'` ${c[E]}\n\n"

	read -p "Continue? y/N " c
	if ( echo $c | grep -i "y" ); then
		rm $Dir$1
		if [ "$1" == "$N" ]; then
			N=$n
		fi
	fi
	Top
}


function Help() {
	for i in "${help[@]}"; do
		printf "\033[1m$i${c[E]}\n"
	done | less -r
	Top
}



# Start
printf "${C[initial]}"

function main() {
	Info

	read -rep "> " U A
	history -s "$U"

	if [ $U ]; then Top

		if [ ! $A ]; then
			case $U in
				h)	Help  ;;

				y)	YTsearch  ;;

				s)	SCsearch ;;

				d)  Local ;;

				p)	playAll  ;;

				r)	readList ;;

				l)	listLists  ;;

				e)	$editor $Dir$N  ;;

				*)	playLink "$U" ;;
			esac

		elif [ $A ]; then
			case $A in

				p)	playSpecific "$U";;

				a)	Add "$U"  ;;

				l)	N=$U  ;;

				L)	createList "$U" ;;

				K)	removeList "$U" ;;

				*)	printf "${C[nProp]}"  ;;
			esac
		fi

	else
		Top
	fi
	main
}

main
