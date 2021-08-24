#!/bin/bash
# curl -sSL enter.smarthome-iot.net | bash /dev/stdin master for testing

if [[ $1 == "master" ]]; then branch=master; fi

source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/_list.sh)
lang=$(whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" "\nSelect your Language" 20 80 10 "${lng[@]}" 3>&1 1>&2 2>&3)
source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/$lang.sh)

githubLatest(){
  curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

startScript() {
  scriptName=$1
  if [[ $branch == "master" ]]; then
    gh_tag=master
    downloadURL="https://github.com/shiot/$scriptName/archive/refs/heads/master.tar.gz"
  else
    gh_tag=$(githubLatest "shiot/$scriptName")
    downloadURL="https://github.com/shiot/$scriptName/archive/refs/tags/${gh_tag}.tar.gz"
  fi
  {
    if [ -d "/root/$scriptName/" ]; then rm -rf "/root/$scriptName/"; fi
    if [ -d "/root/$scriptName-${gh_tag}/" ]; then rm -rf "/root/$scriptName-${gh_tag}/"; fi
    sleep 3
    echo -e "XXX\n29\nSkriptstart wird vorbereitet, bitte warten ...\nXXX"
    wget -qc $downloadURL -O - | tar -xz
    sleep 1
    echo -e "XXX\n56\nSkriptstart wird vorbereitet, bitte warten ...\nXXX"
    mv "/root/$scriptName-${gh_tag}/" "/root/$scriptName/"
    find "/root/$scriptName/" -type f -iname "*.sh" -exec chmod +x {} \;
    sleep 2
    echo -e "XXX\n98\nSkriptstart wird vorbereitet, bitte warten ...\nXXX"
    sleep 0.5
  } | whiptail --gauge --backtitle "© 2021 - SmartHome-IoT.net" "Skriptstart wird vorbereitet, bitte warten ..." 6 80 0
  if [[ $branch == "master" ]]; then
    bash "/root/$scriptName/start_new.sh" "$lang" "master" 
  else
    bash "/root/$scriptName/start.sh" "$lang" 
  fi
}

function startmenu() {
menu=("1" "  ${txt_010}" \
      "" ""              \
      "Q" "  ${txt_999}")

script=$(whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" --title " ${txt_001} " "\n${txt_002}" 20 80 10 "${menu[@]}" 3>&1 1>&2 2>&3)

if [[ $script == "1" ]]; then
  if startScript "pve_HomeServer"; then menu; else exit; fi
elif [[ $script == "Q" ]]; then
  exit
else
  startmenu
fi
}

startmenu
