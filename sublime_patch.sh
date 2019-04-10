#!/bin/bash
#

#############################################################################################
#
# Brief: Script for patching Sublime Text 3 Build 3207 and Sublime Merge Build 1111
# Author: cipherhater <https://gist.github.com/cipherhater>
# Copyright: © 2019 CipherHater, Inc.
#
#############################################################################################

#
##
### Colored output ##########################################################################

RESTORE='\001\033[0m\002'
RED='\001\033[00;31m\002'
GREEN='\001\033[00;32m\002'
YELLOW='\001\033[00;33m\002'
BLUE='\001\033[00;34m\002'
MAGENTA='\001\033[00;35m\002'
PURPLE='\001\033[00;35m\002'
CYAN='\001\033[00;36m\002'
LIGHTGRAY='\001\033[00;37m\002'
LRED='\001\033[01;31m\002'
LGREEN='\001\033[01;32m\002'
LYELLOW='\001\033[01;33m\002'
LBLUE='\001\033[01;34m\002'
LMAGENTA='\001\033[01;35m\002'
LPURPLE='\001\033[01;35m\002'
LCYAN='\001\033[01;36m\002'
WHITE='\001\033[01;37m\002'

echo -en ${RESTORE}

#
##
### Supported version #######################################################################

versions_text='3207'
versions_merge='1111'

support_versions=${versions_text}${versions_merge}

#
##
#### Make sure only root can run our script #################################################
if [[ $EUID -ne 0 ]]; then
    echo -en ${LRED}"\nThis script must be run as root!\n\n"
    echo -en ${RED} 'Goodbay!\n\n'
    exit 1
fi

#
##
### Start menu ##############################################################################

echo -en ${LYELLOW} "\nThis script supports only: \n\n \
	${GREEN}Platform: ${WHITE} Linux x86_64\n\n \
	${GREEN}Sublime Text 3 Build: ${LMAGENTA} $versions_text\n\n \
	${GREEN}Sublime Merge Build: ${LMAGENTA} $versions_merge\n\n"

echo -en ${RESTORE}

#
##
### Function for Sublime Text 3 #############################################################

function textPatching {
echo -en ${YELLOW} '\nChecking Sublime Text path ...\n'

if [[ -f './sublime_text' ]]; then 
	p='.'
else
	echo -en ${WHITE} 
	read -r -p "Please input sublime_text installed path (the directory contains sublime_text): \
			    `echo $'\n> '`" p

	if [[ ! -d "$p" ]]; then
	    echo -en ${LRED} '\nError: '$p' Is not a directory!\n\n'
	    echo -en ${RED} 'Goodbay!\n\n'
	    echo -en ${RESTORE}
	    exit 11
	fi

	if [[ ! -f "$p/sublime_text" ]]; then
	    echo -en ${LRED} '\nError: '$p' Is not a sublime_text installed path!\n\n'
	    echo -en ${RESTORE}
	    echo -en ${RED} 'Goodbay!\n\n'
	    exit 12
	fi

	# Replace "\" with "/"
	p=$(echo $p | sed 's/\\/\//g')

	# Trim trailing "/"
	p=${p%/}

	echo -en ${RED} '\n'
	read -p 'Backup Sublime Text 3 binary? [y/n]: ' bt
	if [ -n $bt ] && [ $bt != "n" ]; then
	    # Backup Sublime Text
	    echo -en ${GREEN} '\nRunning backup: copy "sublime_text" to "sublime_text.orig" ...\n'
	    cp -i "$p/sublime_text" "$p/sublime_text.orig"
	    echo
	fi
fi
echo -en ${RESTORE}
}

#
##
### Function for Sublime Merge ##############################################################

function mergePatching {
echo -en ${YELLOW} '\nChecking Sublime Merge path ...\n'

if [[ -f './sublime_merge' ]]; then
	p='.'
else
	echo -en ${WHITE} 
	read -r -p "Please input sublime_merge installed path (the directory contains sublime_merge): \
			    `echo $'\n> '`" p

	if [[ ! -d "$p" ]]; then
	    echo -en ${LRED} '\nError: '$p' Is not a directory!\n\n'
	    echo -en ${RESTORE}
	    echo -en ${RED} 'Goodbay!\n\n'
	    exit 11
	fi

	if [[ ! -f "$p/sublime_merge" ]]; then
	    echo -en ${LRED} '\nError: '$p' Is not a sublime_merge installed path!\n\n'
	    echo -en ${RESTORE}
	    echo -en ${RED} 'Goodbay!\n\n'
	    exit 12
	fi

	# Replace "\" with "/"
	p=$(echo $p | sed 's/\\/\//g')

	# Trim trailing "/"
	p=${p%/}

	echo -en ${RED} '\n'
	read -p 'Backup Sublime Merge binary? [y/n]: ' bm
	if [ -n $bm ] && [ $bm != "n" ]; then
	    # Backup Sublime Merge
	    echo -en ${GREEN} '\nRunning backup: copy "sublime_merge" to "sublime_merge.orig" ...\n'
	    cp -i "$p/sublime_merge" "$p/sublime_merge.orig"
	    echo
	fi
fi
echo -en ${RESTORE}
}

#
##
### Function select which program to patch ##################################################

function mainWork {
echo -en ${WHITE}
read -n1 -p "Pick a letter to run patching: T - Sublime Text, M - Sublime Merge, or E - Exit script." runPatching

case $runPatching in
	t|T) printf "\n\nStart patching Sublime Text 3.\n" && textPatching;;
	m|M) printf "\n\nStart patching Sublime Merge.\n" && mergePatching;;
	e|E) printf "\n\nGoodbay!\n\n" && exit 0;;
esac
}

mainWork

#
##
### Detect Sublime build number #############################################################

echo -en ${PURPLE} 'Checking Sublime Text/Merge version...\n\n'
if [[ -f "$p/changelog.txt" ]]; then
	v=$(cat "$p/changelog.txt" | grep -P -o '^<h2>.*Build \d{4}' | grep -P -o '\d{4}' | head -n 1)
	echo -en ${LYELLOW}
	read -p "Detected Sublime version *$v*, is it right? [y/n]: " flag
	if [[ -n "$flag" ]]; then
	    case $flag in
		"y" )
		    ;;
		"n" )
		    # Input build number manually
		    echo -en ${WHITE}
		    read -p "Please input your Sublime Text/Merge build number (supported builds are [$support_versions]): `echo $'\n> '`" v
		    ;;
		* )
		    echo -en ${LRED} '\nInvalid input: '$flag'\n'
		    exit 1
	    esac
	fi
else
	echo -en ${LRED} '\nFail detecting Sublime Text/Merge version!\n'
	echo -en ${WHITE}
	read -p "Please input your Sublime Text/Merge build manually (supported builds are [$support_versions]): `echo $'\n> '`" v
fi

#
##
#### Check Sublime Text/Merge if the build is supported #####################################

if [[ ! $support_versions = *"$v"* ]]; then
	echo -en ${LRED} '\nError: Version '$v' is not in support list: ['$support_versions']\n'
	echo -en ${RED} '\nGoodbay!\n'
	echo -en ${RESTORE}
	exit 1
fi

#
##
### Patching binary #########################################################################

function patch {
    prog=$1
    shift
    until [ $# -eq 0 ]
	do
	    printf $2 | dd seek=$(($1)) conv=notrunc bs=1 of="$p/$prog" &> /dev/null
	    shift 2
	done
}

echo -en ${CYAN} '\nStart patching...\n\n'
case $v in
    "3207" )
	st3207='
	0x313658 \x08 0x313659 \x01 0x31365A \xEB 0x31C4F0 \xC3 0x31C4F1 \x90 0x31C55F \x90 0x31C878 \x74 0x31C93E \x90
	0x31C93F \x90 0x31C945 \x90 0x31C946 \x90 0x31C94C \x90 0x31C94D \x90 0x31C951 \x90 0x31C952 \x90 0x31C958 \x90
	0x31C959 \x90 0x31C96D \x75 0x31D1EF \xC3 0x31D667 \x90 0x31D668 \x90 0x31D669 \x90 0x31D66A \x90 0x31D66B \x90
	0x31D66C \x90 0x31D97A \xC3 0x31D97B \x90 0x31D97C \x90 0x31DB62 \x90 0x31DB63 \x90 0x31DB64 \x90 0x31DB65 \x90
	0x31DB66 \x90 0x31DB67 \x90 0x31DB68 \x90 0x31DB69 \x90 0x31DB6A \x90 0x31DB6B \x90 0x31DB6C \x90 0x31DB6D \x90
	0x31DB6E \x90 0x31DB6F \xC3 0x31DB70 \x90 0x31DB71 \x90 0x31DB72 \x90 0x31DB73 \x90 0x31DB74 \x90 0x31DB75 \x90
	0x31DB76 \x90 0x31DB77 \x90 0x31DB78 \x90 0x31DB79 \x90 0x31DB7A \x90 0x31DB7B \x90 0x31DB7C \x90 0x31DB7D \xC3
	0x3BF386 \x90 0x3BF387 \x90 0x3BF388 \x90 0x3BF389 \x90 0x3BF38A \x90 0x3BF38B \x90 0x3BF38C \x90 0x3BF44A \x90
	0x3BF44B \x90 0x3BF44C \x90 0x3BF44D \x90 0x3BF44E \x90 0x3BF44F \x90 0x3BF450 \x90 0x3BF4B6 \x90 0x3BF4B7 \x90
	0x3BF4B8 \x90 0x3BF4B9 \x90 0x3BF4BA \x90 0x3BF4BB \x90 0x3BF4BC \x90 0x3BF4BE \xC3 0x3C03D9 \x0F 0x3C03DA \x01
	0x3C03DB \x90 0x3C03DC \x90 0x3C03DD \x90 0x3C03DE \x90 0x3C03DF \x90 0x3C03E0 \x90 0x3C03EE \x90 0x3C03EF \x90
	0x3C03F0 \x90 0x3C03F1 \x90 0x3C03F3 \x90 0x3C03F4 \x90 0x3C03F5 \x90 0x3C03F6 \x90 0x3C03F7 \x90 0x3C03F8 \x90
	0x3C03FA \x90 0x3C03FB \x90 0x4797A0 \x90 0x4797A1 \x90 0x4797A6 \x90 0x4797A7 \x90 0x4797A8 \x90 0x4797A9 \x90
	0x4797AA \x90 0x4797AB \x90'
	patch sublime_text $st3207
	;;

    "1111" )
	sm1111='
	0x2F6295 \x0F 0x2F6296 \x01 0x2F6297 \x90 0x2F6298 \x90 0x2F6299 \x90 0x2F629A \x90 0x2F629B \x90 0x2F629C \x90
	0x2F62AA \x90 0x2F62AB \x90 0x2F62AC \x90 0x2F62AD \x90 0x2F62AE \x90 0x2F62AF \x90 0x2F62B0 \x90 0x2F62B1 \x90
	0x2F62B2 \x90 0x2F62B3 \x90 0x2F62B4 \x90 0x2F62B5 \x90 0x2F62B6 \x90 0x2F62B7 \x90 0x308216 \x90 0x308217 \x90
	0x308218 \x90 0x308219 \x90 0x30821A \x90 0x30821B \x90 0x30821C \x90 0x30821E \xC3 0x308288 \x90 0x30830A \x90
	0x30830B \x90 0x30830C \x90 0x30830D \x90 0x30830E \x90 0x30830F \x90 0x308310 \x90 0x308312 \xC3 0x30EC74 \xC3
	0x30EC75 \x90 0x30ECE3 \x90 0x30ECE4 \xC3 0x30ECE5 \x90 0x30ECE6 \x90 0x30EF35 \x90 0x30F357 \xC3 0x30FBD3 \xC3
	0x30FCE0 \x90 0x30FCE1 \x90 0x30FCE2 \x90 0x30FCE3 \x90 0x30FCE4 \x90 0x30FCE5 \x90 0x30FCE6 \x90 0x30FCE7 \x90
	0x30FCE8 \x90 0x30FCE9 \x90 0x30FCEA \x90 0x30FCEB \x90 0x30FCEC \x90 0x30FCED \x90 0x30FCEE \x90 0x30FCEF \x90
	0x30FCF0 \x90 0x30FCF1 \x90 0x30FCF2 \x90 0x30FCF3 \x90 0x30FCF4 \x90 0x30FCF5 \x90 0x30FCF6 \x90 0x30FCF7 \x90
	0x30FCF9 \x90 0x30FCFA \x90 0x30FCFB \x90 0x310037 \xEB 0x310F6C \x08 0x310F6D \x01 0x310F6E \xEB 0x3DDC2C \xEB
	0x3DDC45 \x90 0x3DDC46 \x90 0x3DDC47 \x90 0x3DDC48 \x90 0x3DDC49 \x90 0x3DDC4A \x90 0x501B2A \x90 0x501B2B \x90
	0x501B30 \x90 0x501B31 \x90 0x501B32 \x90 0x501B33 \x90 0x501B34 \x90 0x501B35 \x90 0x501B3A \xE9 0x501B3B \x8F
	0x501B3C \x00 0x501B3F \x0F 0x501B40 \x84 0x501B41 \x89 0x501B42 \x00 0x501B43 \x00 0x501B44 \x00 0x7BC5D1 \xEB'
	patch sublime_merge $sm1111
	;;

	* )
    echo -en ${RED} 'Error: Version not supported for patching...\n'
    exit 1
    ;;
esac

echo -en ${LCYAN} 'The patching was done without errors.\n\n'
echo -en ${LGREEN} 'Congratulation!\n'
echo -en ${RESTORE} '\n'
#
exit 0
