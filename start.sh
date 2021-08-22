#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/_list.sh)
lang=$(whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" "\nSelect your Language" 20 80 10 "${lng[@]}" 3>&1 1>&2 2>&3)
source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/$lang.sh)

function githubLatest() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | 
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

function startScript() {
  {
    scriptName=$1
    gh_tag=$(githubLatest "shiot/$scriptName")
    downloadURL="https://github.com/shiot/$scriptName/archive/refs/tags/${gh_tag}.tar.gz"
    wget -qc $downloadURL -O - | tar -xz
    mv "/root/$scriptName-${gh_tag}/" "/root/$scriptName/"
    find "/root/$scriptName/" -type f -iname "*.sh" -exec chmod +x {} \;
  } | whiptail
  bash "/root/$scriptName/start.sh" $lang
}

green='\e[32m'
blue='\e[34m'
red='\e[31m'
clear='\e[0m'

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}
ColorRed(){
	echo -ne $red$1$clear
}

menu(){
echo -ne "
$txt_001
$(ColorGreen \"1)\") $txt_010
$(ColorGreen \"0)\") $txt_999
$(ColorBlue \"$txt_002:\") "
        read a
        case $a in
	        1) startScript "pve_HomeServer" ; menu ;;
		      0) exit 0 ;;
		      *) echo -e $red"$txt_998"$clear; WrongCommand;;
        esac
}

clear
source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/logo.sh)
logo

menu
