#!/bin/bash

set -euo pipefail

##LOGGING
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
lbl=$'\e[1;94m'
prp=$'\e[1;35m'
underline=$'\e[4m'
end=$'\e[0m'

function logit () {
  message=$1
  flair=${2-}
  if test -z "${flair}"; then
    printf "%s\n" " -- ${message}"
  else
    printf "%s\n" "${!flair-} -- ${message}${end}"
  fi
}

## OPTIONS
force=0
help=0
while getopts "fh" opt
do
  case ${opt} in
    f)
      force=1
    ;;
    h)
      help=1
    ;;
    \?)
      logit "Unknown option: ${opt}" red
      exit 1
    ;;
  esac
done
shift "$((OPTIND-1))"

if [[ "${help}" -eq 1 ]]; then
  logit "desciption message" purp
  logit " -f : force - Delete files with service names and replace with folders"
  logit " -h : help - Show this help messsage"
  exit 0
fi

games="$(flatpak run net.lutris.Lutris -aj)"
services="$(echo $games | jq -cr 'map(.service) | unique')"
for service in $(echo $services | jq -cr '.[]'); do
    logit "Checking if directory \"$service\" already exists" yel
    if [[ ! -d "./$service" && -e "./$service" ]]; then
        if [[ $force == 1 ]]; then
            logit "Found existing file called \"$service\"" red
            logit "Removing existing file called \"$service\"" red
            rm -r ./$service
        else
            logit "Found existing file called \"$service\", exiting" red
            exit 1
        fi
    fi
    if [[ ! -e "./$service" ]]; then
        logit "Service directory $service not found" red
        logit "Creating directory \"$service\"" grn
        mkdir "./$service"
    fi
    logit "Checking if manifest file \"$service-manifest.json\" already exists" yel
    if [[ -e "./$service/$service-manifest.json" ]]; then
        logit "Found existing manifest file called \"$service-manifest.json\"" red
        logit "Removing existing manifest file called \"$service-manifest.json\"" red
        rm -r ./$service/$service-manifest.json
    fi
    logit "Creating file \"$service-manifest.json\"" grn
    touch "./$service/$service-manifest.json"
    logit "Importing of games from service $service starting" prp
    echo "[" >> ./$service/$service-manifest.json
    echo "$games" | jq -cr ".[] | select(.service == \"$service\")" | while read -r game; do
        game_name=$(echo $game | jq -r '.name')
        game_details=$(echo $game | jq -r '.details')
        if [[ $service == "egs" ]]; then
          app_id=$(echo $game_details | jq -r '.appName')
        elif [[ $service == "ea_app" ]]; then
          app_id=$(echo $game_details | jq -r '.contentId')
        elif [[ $service == "ubisoft" ]]; then
          app_id=$(echo $game_details | jq -r '.spaceId')
        else
          app_id=$(echo $game_details | jq -r '.id')
        fi
        logit "Adding game $game_name to manifest file \"$service-manifest.json\"" grn
        echo "  {" >> ./$service/$service-manifest.json
        echo "    \"title\": \"$game_name\"," >> ./$service/$service-manifest.json
        echo "    \"target\": \"/usr/bin/flatpak\"," >> ./$service/$service-manifest.json
        echo "    \"startIn\": \"\"," >> ./$service/$service-manifest.json
        echo "    \"launchOptions\": \"run net.lutris.Lutris lutris:$service:$app_id\"" >> ./$service/$service-manifest.json
        echo "  }," >> ./$service/$service-manifest.json
        added=true
    done
    if [[ added ]]; then
        sed -i '$ d' ./$service/$service-manifest.json
        echo "  }" >> ./$service/$service-manifest.json
    fi
    echo "]" >> ./$service/$service-manifest.json
    logit "Importing of games from service $service complete" prp
done
logit "Importing from Lutris complete" lbl