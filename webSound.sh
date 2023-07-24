#!/bin/bash
#############################################################
playlist="demo"		## Default playlist at start
_playlist=$playlist
Dir=~/".webSound/"		## Path to program. Change if moved
Local=$Dir"local/"
Nhits=20			## Number of hits from youtube search
editor="nano"  ## Change to prefered editor
player="mpv --really-quiet" # --load-unsafe-playlists"	##LUP-flag fixes mpv refusing playback of playlist
quality_lo='bestvideo[height<=?480][fps<=?30][vcodec!=?vp9]+bestaudio'
quality_hi='bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio'
mode="p"
#player="omxplayer -o local --vol -900"
#############################################################

set -m

pipe=/tmp/testpipe
if [[ ! -p $pipe ]]; then
  mkfifo $pipe
fi

# \033[ brightness ; colortext ; colorbackground m :: \033[ [0-2] ; 3[0-9] ; 4[0-9] m
# \033[1;32;44m  :: bright green text, on blue background
# \033[0m        :: return to white text on transparent background

source $Dir"functs/formats"

declare -A c
	c[B]="\033[1m"; c[D]="\033[2m"; c[E]="\033[0m"
	c[y]="\033[33m"; c[r]="\033[31m";
	c[g]="\033[32m"; c[b]="\033[34m"
	c[Er]="\033[1;39;41m"
	c[ws]=" w e b s o u n d"; c[lo]=" l o c a l"
	c[yt]=" y o u t u b e"; c[sc]=" s o u n d c l o u d"
	c[bad]=" No proper command. Enter 'h' for help"
	c[dot]="-----------------"


declare -A C
	C[initial]="${c[B]}${c[b]}${c[ws]}${c[E]}\n\n"
	C[default]="${c[b]}${c[ws]}${c[E]}\n\n"
	C[youtube]="${c[r]}${c[yt]}${c[E]}\n\n"
	C[soundcloud]="${c[y]}${c[sc]}${c[E]}\n\n"
	C[Local]="${c[g]}${c[lo]}${c[E]}\n"
	C[downloading]="${c[b]}Downloading${c[E]}"
	C[to]="${c[b]}to${c[E]}"
	C[state0]="${C[B]}${c[y]}state${c[E]}"
	C[state1]="\b\b\b\b\b${c[g]}state${c[E]}"
	C[nProp]="${c[Er]}${c[bad]}${c[E]}\n\n"


fBright="\033[1m"; fDark="\033[2m"; fClear="\033[0m"
cYellow="\033[33m"; cRed="\033[31m";
cGreen="\033[32m"; cBlue="\033[34m"
cPurple="\033[35m"; cTeal="\033[36m"
cError="\033[1;39;41m"; sError=" No proper command. Enter 'h' for help"
sMain=" w e b s o u n d"; sLocal=" l o c a l"
sYoutube=" y o u t u b e"; sSoundcloud=" s o u n d c l o u d"
sDots="-----------------------"

fInitial="$fBright$cBlue$sMain$fClear\n\n"
fDefault="$cBlue$sMain$fClear\n\n"
fYoutube="$fBright$sRed$sYoutube$fClear\n\n"
fSoundcloud="$cYellow$sSoundcloud$fClear\n\n"
fLocal="$cGreen$sLocal$fClear\n"
fSaving="${c[b]}Saving${c[E]}"  #this is dumb
fTo="${c[b]}to${c[E]}"          # same
#fState0="${C[B]}${c[y]}state${c[E]}"
#fState1="\b\b\b\b\b${c[g]}state${c[E]}\n"
fState0="${C[B]}${c[y]}working${c[E]}"
fState1="\b\b\b\b\b\b\b${c[g]}complete${c[E]}\n"
fWrong="${c[Er]}${c[bad]}${c[E]}\n\n"

help=(""
" SYNTAX: [First] (Second)"
""
" [h]   →  This help"
" [u]   →  Update ytdl"
""
" [URL] →  Play [URL]"
" [y]   →  Search youtube"
" [s]   →  Search soundcloud"
" [d]   →  Go to downloaded"
" [p]   →  Play through active playlist"
" [r]   →  Read current playlist"
" [l]   →  List all playlists"
" [e]   →  Edit playlist"
""
" [URL] (a)         → (a)dd [URL] to current playlist"
" [SearchTerm] (p)  → (p)lay [match] from playlist"
" [SearchTerm] (v)  → (v)ideo [stream], v)480p V)1080p"
" [SearchTerm] (i)  → (i)nfo about [matched search]"
" [SearchTerm] (w)  → (w)eb address of [matched]"
" [SearchTerm] (k)  →  remove [match] from playlist"
" [ListName] (l)    →  choose playlist [ListName]"
" [ListName] (L)    →  create playlist [ListName]"
" [ListName] (K)    →  delete playlist [ListName]"
""
" <Enter> to leave active mode "
" <Enter> (double tap) to exit program "
" <q> exits active media <ctrl+c> stops script"
""
" Some preferences(player,editor,etc.) can be made "
" by editing top-section of the script 'webSound.sh'"
"")



function Home() {
	Head #"${C[default]}"
}
function Info() {
	printf "${c[d]} $playlist{`grep '|' -c $Dir$playlist`}\n${c[dot]}${c[E]}\n"
}
function Head() {
	clear
	#echo -e "${c[y]}Changes made for grep. Remember to test and push update${c[E]}"; echo
  [ -z "$1" ] && printf "${C[default]}" || printf "$1\n"
}

play() {
	sleep 10; Head &
	$player "$1" #&
}

function Add() {  # << title link
	#E=`printf "$(youtube-dl --flat-playlist -e "$1")\n" | head -n 1`

	#if [ ! "$E" ]; then E="Playlist?"; fi

	#printf "\n|$E\n"$1"\n" >> $Dir$playlist
	#printf " ${c[b]}Added:${c[E]}  $E\n    ${c[b]}To:${c[E]}  $playlist\n"

	title="$1" ; link="$2"
	[ -z "$link" ] &&
		link="$1" &&
		printf " Grabbing title..\r" &&
		title=` youtube-dl -e "$1" `
	

	printf "\n|$title\n$link\n" >> $Dir$playlist
	printf " ${c[b]}Added:${c[E]}  $title\n    ${c[b]}To:${c[E]}  $playlist\n"
	read -p " .."
}


function Download() {  # << title link
	#title=`youtube-dl -e $1`
	#name=`printf "$title\n" | sed 's/\ /_/g'`
	#printf " ${C[saving]} $title\n ${C[to]} $Local ... "
	#state 0
	#youtube-dl -qo $Local$name -f bestaudio $1
    	#printf "\n|$title\n$Local$name\n" >> $Dir"llocal"
	#state 1
	
  msg='Done'
	title=$1
	fname=`printf "$title" | sed 's/\s$//g' | sed 's/\s/_/g'`   ## Does \n result in ending extra _ ?
	printf " ${C[downloading]} $title\n ${C[to]} $Local\n" #"$Dir"local/\n"
	#echo $fname
	#  youtube-dl -qo $Local$fname -f bestaudio $2
	printf "$cYellow Preparing" #state 0
  size1=` youtube-dl -F $2 | grep 140 | awk '{print $12}' `
  size2=` echo $size1 | cut -dM -f1 | sed 's/\.//g'`
  size2=$(( ( $size2*1024*1024 ) / 100 ))
  
  youtube-dl -qf 140 $2 -o $Local"$fname" --socket-timeout 60 &
  
  odd=1
  while [ ! -f "$Local$fname"* ]; do 
    (( $odd )) && printf "." && odd=0 || odd=1
    sleep 1
  done
 
  tput civis

  old2=0
  speed=0
  sample=1
  while [ -f "$Local$fname.part" ]; do
    part1=` ls -oh "$Local$fname"* | grep .part | awk '{print $4}' `
    part2=` ls  -o "$Local$fname"* | grep .part | awk '{print $4}' `
    part1=${part1:-$size1}
    part2=${part2:-$size2}
    perc=$(( ($part2*100)/$size2 ))
    #-
    (( $sample == 1 )) && old2=$part2
    speed=$(( $speed + ( (part2-old2 ) - $speed ) /$sample ))
    seconds=$(( ($size2-$part2)/($speed+1) ))
    old2=$part2
    (( $sample < 20 )) && sample=$(($sample+1))
    (( $odd )) && time=$(printf "%*s" 10 $(human_time $seconds)) && odd=0 || odd=1
    #-

    printf "                                     "
    printf "\r  $part1/$size1  $perc%% $time "
    
    # Stop download by pressing Enter
    fin=1; sleep 1 & (read -t 1 && wait ) || fin=0; (( $fin )) && msg='Interrupted' && break
    #sleep 1

  done
  
  #[ -f $Local*.part ] && rm $Local*.part
  
  [ -f "$Local$fname" ] &&
  printf "\n|$title\n$Local$fname\n$2\n" >> $Dir"llocal"
	
  [ -f "$Local$fname".temp ] && rm "$Local$fname".temp

  tput cnorm

  pkill youtube-dl >/dev/null
  
  printf "                                      "
  printf "\r $cTeal$part1 / $size1  $msg$fClear "
  ([ $msg == "Interrupted" ] &&
    read -p ' Save partly downloaded file? y/N: ' A && (
      [[ -z $A ]] && [ -f $Local$fname.part ] && rm $Local$fname.part ) ) ||  
	read -p " .."
}


function state() {
	#if [ $1 == 0 ]; then
		#state="${C[state0]}"
	#else
		#state="${C[state1]}"
	#fi
	#printf $state

	[ $1 -eq 0 ] && printf "$fState0" || printf "$fState1"

}


function YTsearch() {
	while true; do #clean "${C[youtube]}"
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then Head; break
		else
			S="`echo "$s" | sed 's/\ /+/g'`"
			w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
			grep -e "- Duration" | grep '\[' | 
			sed 's/[ \t]*//' | sed 's/]/ \t/' | sed 's/\[//' | sed 's/ Duration://' |
			head -n "$Nhits"
			#grep "Play now" -A 2 |
			#grep "\[" |
			#sed 's/[ \t]*//' |
			#sed 's/ Duration://' |
			#head -n "$Nhits"

			while true; do read -rep ' n (a|d): ' P A

				if [ ! "$P" ]; then break; fi

				link=`w3m -dump -o display_link_number=1 https://www.youtube.com/results?search_query="$S" |
					grep "References:" -A 200 |
					grep "\["$P"\]" |
					awk '{print $2}' `

				if [ ! "$A" ]; then
					$player $link #&

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
	while true; do #clean "${C[soundcloud]}"  # Title
		read -rep ' Search: ' s
		history -s "$s"

		if [ ! "$s" ]; then break #Top; break
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
					$player $link #&

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



#function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
#
function Search() {
  clear; printf "${C[youtube]}"
  read -ep 'Search: ' ans
	history -s "$ans"
  [[ -z "$ans" ]] && Head && return
  history -s "$ans"
  ans=` echo $ans | sed 's/ /+/g' `
  scrape "$ans"
}
#
function scrape() {
  page=` w3m -dump -o display_link_number=1 "google.com/search?q=youtube+%2B+$1" `  # "https://www.google.com/search?q=youtube+%2B+$1" `
  N=0
  for nr in ` printf "%s\n" "$page" | grep YouTube | fgrep "[" | cut -d] -f1 `; do
    ti=` printf '%s\n' "$page" | fgrep "$nr" | head -n1 | cut -d']' -f2- | awk -F'- YouTube' '{print $1}' `
    du=` printf '%s\n' "$page" | fgrep "$nr" -A5 | grep Duration `
    li=` printf '%s\n' "$page" | fgrep "$nr" | tail -n1 | cut -d] -f2- | cut -d= -f2- | cut -d'&' -f1 `
    TI[$N]="$ti"
    DU[$N]="$du"
    LI[$N]="$( urldecode $li )"
    N=$((N+1))
  done
  show
}
#
function show() {
  Head "${C[youtube]}"
  
  for ((n=0; n<N; n++)); do
    [[ $1 ]] && [[ n -eq $1 ]] && selection=$fBright || selection=$fClear  # Highlight selected
    printf "$selection%s:\t%s / %s\n" "$((n+1))" "${TI[$n]}" "${DU[$n]}"
  done
  echo
  [[ -z $1 ]] && Select
}
#
function Select() {
  read -ep "`printf "Select: n\b"`" pik opt
  history -s "$pik"
  [[ -z "$pik" ]] && Search && return
  pik=$((pik-1))
  show $pik
  case $opt in
    p) fg ;; # `jobs -l | grep $jid | cut -c2` ;;
      #printf "$fDark Audio stream .. $fClear" #: s ..\n" "${TI[$pik]}
      #mpv "${LI[$pik]}" --no-video --really-quiet ;;
      #show ;;
    v|vl)
      printf "$fDark Video stream .. $fClear" #: s ..\n" "${TI[$pik]}
      #pkill mpv
      $player "${LI[$pik]}" --really-quiet --ytdl-format=$quality_lo -vo=tct #&
      ;;
      #show ;;
    V|vh)
      printf "$fDark Video stream .. $fClear" #: s ..\n" "${TI[$pik]}
      #pkill mpv
      $player "${LI[$pik]}" --really-quiet --ytdl-format=$quality_hi #&
      ;;
    a)
      Add "${TI[$pik]}" "${LI[$pik]}" ;;
      #show ;;
    d)
      #printf "Downloading: %s .. " "${TI[$pik]}"
      #youtube-dl -f 140 "${LI[$n]}" >2/dev/null
      Download "${TI[$pik]}" "${LI[$pik]}" ;;
      #read
      #show ;;
    i)
      getInfo ${LI[$pik]} ;; #youtube-dl --get-description "${LI[$pik]}" | less ;;
      #show ;;
    w)
      printf " $cBlue${TI[$pik]}$fClear\n"; echo " ${LI[$pik]}"; read -p ' ...' ;;
    *)
      printf "$fDark Audio stream .. $fClear" #: s ..\n" "${TI[$pik]}
      #pkill mpv
      $player "${LI[$pik]}" --no-video --really-quiet #> /dev/null 2>&1 #&
      ;;
      #show ;;
  esac
  show
}

playVideo() {
  printf "`readTitle $1`\n"
  case $2 in
    v|vl)
      printf "$fDark Video stream .. $fClear" #: s ..\n" "${TI[$pik]}
      pkill mpv
      $player `readLink $1` --really-quiet --ytdl-format=$quality_lo --vo=tct ;;# & jid=`echo $!` ;;
      #show ;;
    V|vh)
      printf "$fDark Video stream .. $fClear" #: s ..\n" "${TI[$pik]}
      pkill mpv
      $player `readLink $1` --really-quiet --ytdl-format=$quality_hi ;;#& jid=`echo $!` ;;
  esac
  Head #echo 
}


function SearchOLD() {
sc='https://soundcloud.com/search?q='
yt='https://www.youtube.com/results?search_query='
base=`[ $1 == s ] && echo "$sc" || ([ $1 == y ] && echo "$yt")`
domain=`[ $1 == s ] && printf "${C[soundcloud]}" || ([ $1 == y ] && printf "${C[youtube]}")`

while true; do Head "$domain\n" #SearchLoop

read -rep " Search: " S
[ -z "$S" ] && Head && return
history -s $S

S=`echo $S | sed 's/\ /+/g'`
dump=`w3m -dump -o display_link_number=1 "$base""$S"`

hits=`echo "$dump" |
	grep -e "- Duration" |
	grep '\[' |
	sed 's/[ \t]*//' |
	sed 's/]/ \t/' |
	sed 's/\[//' |
	sed 's/ Duration://' |
	head -n "$Nhits" 
	`

#echo
lhits=`echo "$hits" | cut -d ' ' -f2- | grep -nP '.' `
#echo "$lhits"
#echo

declare -A refs; c=1
for r in `echo "$hits" | cut -d ' ' -f1`; do
	refs[$c]=$r
	((c++))
done

while true; do #PickLoop
Head "$domain"
echo; echo "$lhits"; echo
read -rep " n a|d|i: " U A Q
[ -z $U ] && break

r="\[${refs[$U]}\]"
link=`
	echo "$dump" |
	grep "References:" -A200 |
	grep "$r" |
	awk '{print $2}'
	`

title=`
	echo "$dump" |
	grep -e "- Duration:" |
	grep $r |
	cut -d ']' -f2 |
	sed 's/Duration: //'
	`
nfield=`printf "$(echo $title | sed 's/-/\\n/g')" | wc -l`
title=`echo "$title" | cut -d'-' -f-$nfield`


[ -z "$A" ] && (
 echo -e "\n$cBlue Playing$fClear $title"
 $player $link #&
)
[ "$A" ] &&
([ "$A" == "a" ] && Add "$title" "$link") ||
([ "$A" == "d" ] && Download "$title" "$link") ||
([ "$A" == "v" ] && playVideo "$title" "$link" "$Q") ||
([ "$A" == "i" ] && getInfo "$link") ||
([ "$A" == "l" ] && printf " $title\n $link\n" && read -p " ..") ||
printf " [Number] \t → play choice\n [Number] (a|d|i) \t → add/download choice\n [empty] \t → back to search\n"

done #PickLoop
done #SearchLoop

Head; main

}


function Local() {
  _playlist=$playlist
  playlist="llocal"
  mode="d"

  while true; do Head "${C[Local]}"
    grep '|' $Dir$playlist | cut -d'|' -f2-
    echo ${c[dot]}   
    read -rep " RegX: " U opt
        
    [[ -z "$U" ]] && mode="p" && break
    
    case $U in
      p)
        sleep 10 && kill -s STOP `pgrep mpv` && bg &
        fg ;;
        #echo $opt > $pipe
        #sleep 5 && echo > $pipe &
        #fg >/dev/null ;; #`jobs -l | grep $jid | cut -c2` ;;
      e)
        $editor $Dir$playlist ;;
      *)
        if [[ -z "$opt" ]]; then
          playSpecific "$U" 
        else
          case "$opt" in
            i)
              getInfo ` readLink "$U" ` ;;
            w)
              showLink "$U" ; read -p ' ..';;
            v)
              printf "$fDark Video stream .. $fClear"
              #pkill mpv
              $player `readLink "$U"` --really-quiet --ytdl-format=$quality_lo --vo=tct #&
              ;;
            V)
              printf "$fDark Video stream .. $fClear"
              #pkill mpv
              $player `readLink "$U"` --really-quiet --ytdl-format=$quality_hi #&
              ;;
            k)
              # Use regex to find link to file and remove its path,
              # and then rewrite playlist, excluding that match!
              #removeElement "$U"
              clear ;;
          esac
        fi
    esac
  done   
    
    #while true; do Head "${C[Local]}"
    #    grep '|' $Dir$playlist
    #    
    #    read -rep " RegX: " U A
    #    
    #    if [[ -z "$U" ]]; then
    #        break
    #    elif [ -z "$A" ]; then
    #        if [ "$U" == "e" ]; then 
		#		$editor $Dir$playlist
    #        else
    #            playSpecific "$U"
    #            #Local
    #        fi
       
        #!use regex to find link to file and remove its path, and then rewrite playlist, excluding that match!
		#elif [ "$A" == "k" ]; then
		#    removeElement "$U"
		#    clear
		#    #Local
    #    fi
    #done
    
  playlist=$_playlist
	
    # oldSelect
    
    #Head; main
  Head
}


#function oldSelect() {
#	declare -A items
#	count=1
#	for i in `ls $Local`; do
#		echo "$count: $i"
#		items[$count]="$i"
#		count=$((count+1))
#	done
#	echo
#	while true; do
#		read -rep " n (r): " U A
#		if [ -z "$U" ]; then
#			break
#		elif [ -z "$A" ]; then
#			$player $Local${items[$U]}
#			Local
#		else
#			if [ "$A" == "r" ]; then
#				rm $Local${items[$U]}
#				Local
#			else
#				printf "\n${C[nProp]}"; fi
#		fi
#	done
#}


function playAll() {
	printf "${c[b]} @$playlist ${c[E]}\n"
	printf "${c[b]}`grep '|' $Dir$playlist | cut -d"|" -f1-`${c[E]}\n"
  #pkill mpv
	$player `grep -v '|' $Dir$playlist` #2>/dev/null #& jid=`echo $!` 
  Head
}


function getPid() {
  ppid=`pgrep mpv` #`ps -a | grep mpv | awk '{print $1}'`
  #echo Pid: $ppid
  echo $ppid
}

function getJid() {
  pjid=`jobs -l | grep "$(getPid)" | cut -c2`
  #echo Jid: $pjid
  echo $pjid
}

function playSpecific() {
  #expr='\|.*'$1
  #history -s "$1"
  #printf "` grep -P $expr -i $Dir$playlist `" | grep "|"
  #$player ` grep -P $expr -i $Dir$playlist -A 1 | grep -v "|" `
 
  #echo "$mode"
  #printf "`readTitle $1` \n"
  readTitle $1
  #[ "$mode" = "p" ] && echo `readLink $1` || echo `readPath $1`
  if [ "$mode" = "p" ]; then 
    pkill mpv
    $player --vid=no $(printf "`readLink $1`") & #< $pipe & #> /dev/null #2>&1  #&
  else
    pkill mpv
    $player --vid=no $(printf "`readPath "$1"`") & #< $pipe & # > /dev/null 2>&1 &
  fi
  
  #Head

  #[ "$mode" = "p" ] && printf "`readLink $1`" || printf "`readPath "$1"`"
  #read 
  
    #if [ ! "`grep -i $1 $Dir$playlist | grep '|'`" ]; then
	#	printf "${c[b]}`grep -i $1 $Dir$playlist`${c[E]}\n\n"
	#	$player `grep -i $1 $Dir$playlist` 2>/dev/null
	#else
	#	f=(); f+=(`grep -iA 1 $1 $Dir$playlist | egrep -v '\|'`)
	#	printf "${c[b]}`grep -i $1 $Dir$playlist`${c[E]}\n\n"
	#	$player ${f[@]} 2>/dev/null
	#fi
}


function playLink() {
	if (echo $1 | grep /); then
		echo "Grabbing content.."
		E=`youtube-dl --flat-playlist -e $1 2>/dev/null`
		Head
		printf "${c[b]} $E ${c[E]}\n"
    #pkill mpv
		$player $1 #2>/dev/null #&
	else
		printf "${C[nProp]}"
	fi
}

function readTitle() {
  expr='\|.*'$1
  #grep -P $expr -i $Dir$playlist | cut -d'|' -f2-
  ##
  tput sc
  n=2
	while read title; do
    tput cup $n 20; printf "$title"
    n=$((n+1))
  done <<< `grep -P $expr -i $Dir$playlist | cut -d'|' -f2-`
  tput rc
}

function readLink() {
  expr='\|.*'$1
  grep -P $expr -i $Dir$playlist -A 2 | egrep "^[^|]" | egrep -v "$Local"
}

function readPath() {
  expr='\|.*'$1
  grep -P $expr -i $Dir$playlist -A 2 | egrep "^[^|]" | grep "$Local"
}


function getInfo() {
	
  json=`youtube-dl --dump-json "$1"`
  title=`echo "$json" | jq .title | sed 's/"//g'`
  views=`echo "$json" | jq .view_count`
  views=`sci_num $views`
  #rating=`printf "%.1f" $(echo "$json" | jq .average_rating | awk '{print 100*$1/5+.5}')`
  #rating=`printf "%.1f" $rating`
  _upload=`echo "$json" | jq .upload_date | sed 's/"//g'`
  upload=""
  for ((i=0;i<${#_upload};i++));do
    upload=$upload${_upload:$i:1}
    case $i in
      3|5) upload=$upload"-" ;;
    esac
  done
  duration=`echo "$json" | jq .duration`
  duration=`human_time $duration`
  disc=`echo "$json" | jq .description | sed 's/"//g'`
  #clear
  Head
  printf "$cTeal $title$fClear\n$cYellow%s$fClear\n\n$disc\n" \
    " Upload: $upload  Views: $views  Duration: $duration" | less -R

  
  #link=$1
  #youtube-dl --get-description "$1" | less
	#return  
}


function oldVideo() {
	title="$1"
	link="$2"
	fileV=$Dir.tmpVid.mp4
	#fileA=$Dir.tmpAud.mp4

	flags=`                                   # medium as playlist
	 [ $3 ] && (
	 [ $3 == h ] && echo "-xterm256unicode"  # high
   [ $3 == l ] && echo "-fast"             # low
   [ $3 == b ] && echo "-nocolor"          # bad
   [ $3 == B ] && echo "-nocolor -fast"    # like really bad
   )
	`
	
	printf "\n$cBlue Preparing video of$fClear$fBright $title $fClear\n "
	state 0
	getInfo "$link" & >/dev/null
	youtube-dl -qo $fileV $link  -f  18 #160+140 $link
	#youtube-dl -qo $fileA $link  -f  140 & #18 #160+140 $link
	wait
	state 1
	read -p " Press enter to start "

	$player $fileV #&
	hiptext $fileV $flags -width 90

	rm $fileA $fileV

}


function createList() {
	touch $Dir$1; playlist=$1

	printf "${c[b]} Created Playlist $1 ${c[E]}\n"
}


function listLists() {
  tput sc
  tput cup 0 20
  printf "${c[b]} %-10s%*s${c[E]}\n" "Playlist" 4 "Items"
  n=2
	for i in `ls $Dir | egrep -iv 'functs|websound|local'`; do
		tput cup $n 20
    printf " %-10s %*s\n" $i 4 `grep '|' -c $Dir$i`
    n=$((n+1))
	done; echo
  tput rc
}


function readList() {
  #[ "$1" = "r" ] && grep '|' $Dir$playlist | less || (Head && grep '|' $Dir$playlist )
  
  if [ "$1" == "R" ]; then grep '|' $Dir$playlist | less; return; fi
  n=2
  tput sc
	while read title; do
    tput cup $n 20; printf "$title"
    n=$((n+1))
  done <<< `grep '|' $Dir$playlist`
  tput rc
  #Head
}


function goToList() {
	new=` ls $Dir | egrep -iv 'websound|local' | grep -iE $1 | head -n 1 `
	[ $new ] && playlist=$new || printf "$cError No matching playlist $fClear\n"
}


function removeList() {
	printf "${c[b]} Removes playlist $1, with `grep '|' -c $Dir$1` item(s)\n"
	printf "${c[dy]}`cat $Dir$1 | grep '|'` ${c[E]}\n\n"

	read -p "Continue? y/N " c
	if ( echo $c | grep -i "y" ); then
		rm $Dir$1
		if [ "$1" == "$playlist" ]; then
			playlist=$_playlist
		fi
	fi
	Head
}



function removeElement() {
    
    hits=`grep -Pi '\|.*'$1 $Dir$playlist`
    echo "$hits"
    echo
    read -rep "Delete? y/N : " D
    
    if [ "$D" != "y" ]; then return; fi    
    
    if [ $playlist == "llocal" ]; then
        rm $Local"`ls $Local | grep -Pi $1`"
    fi
    
    tmpList=`grep -iv "$(grep -A1 "$hits" $Dir$playlist | grep -v '|')" $Dir$playlist`
    echo "$tmpList" | grep -iv "$hits" > $Dir$playlist

}


function showLink() {
  T=`readTitle "$1"`
  L=`readLink "$1"`
  printf "
 $cBlue$T$fClear
 $L\n"
  echo
}

function update() {
  read -p "Update youtube-dl? y/N: " up
  [[ -z "$up" ]] || (
    sudo curl -sSL https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl 2>/dev/null
    sudo chmod a+rx /usr/local/bin/youtube-dl
  )
  Home
}


function Help() {
  clear
  for i in "${help[@]}"; do
		printf "\033[1m$i${c[E]}\n"
	done | less -r
	
  Head

}



function Quit() {
  tput civis
  Head "\033[2m${c[ws]}${c[E]}"
  sleep .5
  clear
  tput cnorm
  exit
}


function SummonPlayer() {
  set -m
  tput civis; tput sc
	printf "$D ▶ Play/Pause:Space | Stop:Q | Seek:Arrows"
  (sleep $1 && (( `ps -a | grep mpv | wc -l` )) && kill -s STOP `pgrep mpv` && kill -s CONT `pgrep mpv` &)
  fg >/dev/null
  tput rc;
  printf "                                             \r"; tput cnorm
}

function main() {
	dbq=`date +%s`  # double quit
	while true; do
  
  [[ -z `ls "$Dir" | egrep "^$playlist$"` ]] && 
    playlist=`ls "$Dir" | egrep -v 'functs|local|webSound' | head -n1`
	
  Info
	
  read -rep "> " U A
	history -s "$U"
	
  Head
	if [ $U ]; then #Head

		if [ ! $A ]; then
			case $U in
				h)	Help  ;;
        q)  Quit  ;;
			y|s)	Search $U ;;
				d)	Local ;;
				p)  SummonPlayer 5 ;;
			r|R)	tput civis; readList $U; tput cnorm ;;
				l)	tput civis;  listLists ; tput cnorm  ;;
				e)	$editor $Dir$playlist  ;;
        u)  update ;;
				*)	playSpecific "$U" ;;

			esac

		elif [ $A ]; then
			case $A in

				p)	playLink "$U";;
				a)	Add "$U"  ;;
				i)
          ((`echo "$U" | grep http | wc -l`)) && getInfo "$U" || getInfo `readLink "$U"` ;;
        w)  showLink "$U" ;;
				#v)  video `readLink "$U"`  ;;
      v|V)  playVideo "$U" "$A" ;;
        d)  Download "`readTitle $U`" "`readLink $U`" ;;
				k)  removeElement "$U"; Head ;;
				l)  goToList $U  ;;
				L)	createList "$U" ;;
				K)	removeList "$U" ;;
				*)	printf "${C[nProp]}"  ;;

			esac
		fi

	else
		# double quit check
		[ $((`date +%s`-$dbq)) -lt 1 ] && Quit || dbq=`date +%s`
		
	fi
	
	done

}

# Start
v=1
clear
tput civis
if [[ $v = 0 ]]; then
  printf "${c[D]}${c[ws]}${c[E]}${c[b]} "
  for l in ${c[ws]}; do
    printf "\b\b" #; sleep 0.5
  done
  for l in ${c[ws]}; do
    printf "$l "; sleep 0.05
  done
  sleep 0.5
else
  for l in ${c[ws]}; do
    tput blink; printf " \033[34m$l\033[0m"; sleep .05
  done
  sleep 1
  tput cup 0 0; printf "\033[34m w e b s o u n d\033[0m"; sleep .5
fi
echo;echo
sleep .1 && tput cnorm &



#Home; 
main

