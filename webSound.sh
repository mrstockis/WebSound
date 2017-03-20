#!/bin/bash
#############################################################
N=1			##Default playlist at start
Folder=~/.webSound/	##Location of WebSound-folder (if need to move folder)
#clear 			##Clear terminal at start

###Player - mpv|cvlc|omxplayer
play="mpv --vid=no --quiet"
#play="cvlc something something"
#############################################################

#Array of color#
declare -A c; c[E]="\033[0m"; c[d]="\033[2m"; c[D]="\033[22m"
c[by]="\033[1;33m"; c[bb]="\033[1;34m"; c[r]="\033[31m"; c[b]="\033[34m"; c[dy]="\033[2;33m"

printf "\n${c[b]}          WebSound${c[E]}"
while true; do
printf "${c[d]}\n  Playlist $N: $(grep '#' -c $Folder$N) item(s)\n----------------------------------\nEnter 'h' for help .. or ${c[D]} command: "
read U A

if [ $U ]; then clear; printf "${c[d]}----------------------------------${c[E]}\n\n"; if [ ! $A ]; then case $U in
		h)
		printf "${c[by]}$(cat "$Folder"help)${c[E]}\n"  ;;
		p)
		printf "${c[bb]}  Starts Playlist $N: ${c[E]}\n\n"
		$play $(grep -v '#' $Folder$N) 2>/dev/null  ;;
		r)
		cat $Folder$N 2>/dev/null || printf "${c[r]} No such playlist${c[E]}\n"  ;;
		R)
		printf "${c[bb]} Playlist	Items\n${c[E]}"
		for i in $(ls $Folder | egrep -iv 'websound|help'); do
		printf "${c[b]} $i		$(grep '#' -c $Folder$i)${c[E]}\n"; done  ;;
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
	printf "#\n$U\n\n" >> $Folder$N
	printf "${c[bb]} Added:  $U\n To:  $N ${c[E]}\n${c[E]}"  ;;
	p)
	N=$U ;;
	P)
	touch $Folder$U
	printf "${c[bb]} Created Playlist $U ${c[E]}\n"  ;;
	K)
	(printf "${c[bb]} Remove Playlist $U, with $(grep '#' -c $Folder$U) item(s)?\n" && printf "${c[dy]}$(cat $Folder$U) ${c[E]}\n" && rm -i $Folder$U) || printf "${c[r]} No such playlist found${c[E]}\n"  ;;
	esac
  fi

else 	printf "${c[r]}\n No proper command given${c[E]}\n"

fi
done

###############Coming

###: Update
#elif [ $U == "U" ]; then
#git pull (specificly!) "$Folder"install | wait
#bash "$Folder"install


###: ArrayPlaylist
#NewPlaylist - Contructs new separate array in PlayRay.sh
	#if [ $1 == "p" ];	#printf "\ndeclare -A "$1" \n"
#AddSong - Append arg1{titel} arg2{yurlLink} to current playlist ($N[arg1]+=youtube-dl [arg2]);
	#bash PlayRay.sh $U $A
#ReadArray(s) - Print all keys {! \"$N" [*]} in current array, or grep all elements in PlayRay.sh by pattern;
	#grep declare PlayRay.sh | awk '{print $3}'
#Edit array - No freaking idea // print all keys with #, ask for index[x⁰¹] to claim index[y⁰¹];
	#// maybe just move the rows in the file(txtEditor)..
#Delete - vi-editor will after grep identified row, counted its elements(n¹);
	#go there by <j> and delete with <dd> (n¹) times;
	#or just Go to the file and erase the array by hand(txtEditor)..
		#nano PlayRay.sh
