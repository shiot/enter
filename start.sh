#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/_list.sh)
lang=$(whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" "\nSelect your Language" 20 80 10 "${lng[@]}" 3>&1 1>&2 2>&3)
source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/$lang.sh)

githubLatest(){
  curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

startScript() {
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

whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" --title "${txt_001}" "\n${txt_002}" 20 80 10 \
"1" "  ${txt_010}" \
"Q" "  ${txt_999}"
script=$?
if [[ $script == "1" ]]; then
  startScript "pve_HomeServer"
elif [[ $script == "Q" ]]; then
  exit 0
fi
