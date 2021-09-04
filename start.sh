#!/bin/bash
# curl -sSL enter.smarthome-iot.net | bash /dev/stdin master for testing

if [[ $1 == "master" ]]; then branch=master; fi

source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/logo.sh)
clear
logo 

if [ -f "/opt/smarthome-iot_net/config.sh" ]; then
  source /opt/smarthome-iot_net/config.sh
else
  source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/_list.sh)
  var_language=$(whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" "\nSelect your Language" 20 80 10 "${lng[@]}" 3>&1 1>&2 2>&3)
fi

# check if language File exist, if not load english
if curl --output /dev/null --silent --head --fail "https://raw.githubusercontent.com/shiot/enter/master/language/${var_language}.sh"; then
  source <(curl -sSL https://raw.githubusercontent.com/shiot/enter/master/language/${var_language}.sh)
else
  source https://raw.githubusercontent.com/shiot/enter/master/language/en.sh
fi

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
    if bash "/root/$scriptName/start.sh" "${var_language}" "master"; then
      rm -rf "/root/$scriptName"
      startmenu
    else
      rm -rf "/root/$scriptName"
      startmenu
    fi
  else
    if bash "/root/$scriptName/start.sh" "${var_language}"; then
      rm -rf "/root/$scriptName"
      startmenu
    else
      rm -rf "/root/$scriptName"
      startmenu
    fi
  fi
}

function startmenu() {
menu=("1" "  ${txt_010}" \
      "" ""              \
      "Q" "  ${txt_999}")

if [ ! -f "/opt/smarthome-iot_net/config.sh" ]; then startScript "pve_HomeServer"; fi

script=$(whiptail --menu --nocancel --backtitle "© 2021 - SmartHome-IoT.net" --title " ${txt_001} " "\n${txt_002}" 20 80 10 "${menu[@]}" 3>&1 1>&2 2>&3)

if [[ $script == "1" ]]; then
  startScript "pve_HomeServer"
elif [[ $script == "Q" ]]; then
  exit
else
  startmenu
fi
}

startmenu
