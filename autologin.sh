#!/bin/bash
# THIS IS A BASH SCRIPT TO AUTOMATICALLY AUTHENTICATE YOURSELF AT YOUR OPNSENSE FIREWALL IF CAPTIVEPORTAL IS ENABLED


# ----- Configuration -----
USERNAME="your username here"
PASSWORD="your password here"
FIREWALL_URL="http://192.168.1.1/" # Replace with the Url of your Firewall captiveportal
SLEEP_TIME=20 # time until next automated check if connection still authorised, default = 20
CONNECT_TIMEOUT=5 # time to wait for a respond from the server, will wait $ long if no server reachable / no connection, default = 5

# A short guide on the Firewall_url variable: this is the local IP address / URL of your opnsense firewall instance.
# You can find this one by simply opening the log-in page from your firewall and copying the IP / URL from the webpage
# The Format should be the similar to the default one, no subdirectories
# -------------------------

# It is not recommended to change anything below... (unless you know what you are doing)
# feel free to change on your behalf
STATUS_URL="${FIREWALL_URL}api/captiveportal/access/status/0/"
LOGIN_URL="${FIREWALL_URL}api/captiveportal/access/logon/0/"
VERSION="v1.0"
trap 'echo "INFO: Script stopped by user"; exit 0' SIGINT

timestamp() {
  command date '+%H:%M:%S'
}

echo "$(timestamp) INFO: Starting autologin.sh - Version: ${VERSION}"

command -v curl >/dev/null 2>&1 || { echo -e "$(timestamp) Critical: curl missing \n Check your package-manager if you have curl installed (Like who doesn't have curl installed?)"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "$(timestamp) Critical: jq missing \n Check your package-manager if you have jq install and if not do so" ; exit 1; }

if [ "$USERNAME" = "your username here" ]; then
   echo "WARNING: It seems like your username is still the default option, which is almost certainly a mistake!"
fi
if [ "$PASSWORD" = "your password here" ]; then
   echo "WARNING: It seems like your password is still the default option, which is almost certainly a mistake!"
fi
if [ "$FIREWALL_URL" = "http://192.168.1.1/" ]; then
  echo "WARNING: Using the default firewall url, ignore this if you know what you are doing"
fi

isLoggedIn() {
  STATUS_RESPONSE=$(curl -s -X POST "$STATUS_URL" \
    --connect-timeout "$CONNECT_TIMEOUT" \
    -H "Referer: ${FIREWALL_URL}" \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H "Origin: ${FIREWALL_URL}" \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    --data-raw 'user=&password='
  )
  CLIENT_STATE=$(jq -r '.clientState' <<< "$STATUS_RESPONSE")

  if [ "$CLIENT_STATE" == "AUTHORIZED" ]; then
    return 0
  else
    return 1
  fi
}
login() {
  curl -s -X POST "$LOGIN_URL" \
    --connect-timeout $CONNECT_TIMEOUT \
    -H "Referer: ${FIREWALL_URL}" \
    -H 'X-Requested-With: XMLHttpRequest' \
    -H "Origin: ${FIREWALL_URL}" \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Priority: u=1' \
    --data-raw "user=${USERNAME}&password=${PASSWORD}"

  if isLoggedIn; then
    echo "$(timestamp) INFO: Login successful"
  else
    echo "$(timestamp) INFO: Login unsuccessful, check password or try again"
  fi
}


while true; do
   CONNECTION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$STATUS_URL" --connect-timeout "$CONNECT_TIMEOUT" )
   if [ "$CONNECTION_RESPONSE" = "000" ]; then
     echo "$(timestamp) INFO: no connection to server"
   elif [ "$CONNECTION_RESPONSE" = "200" ]; then
     if isLoggedIn; then
       echo "$(timestamp) INFO: already authorised"
     else
       RESULT=$(login)
       echo "$RESULT"
     fi
   else
     echo "$(timestamp) EXCEPTION: Server response unexpected: ${CONNECTION_RESPONSE}"
   fi
   sleep "$SLEEP_TIME"
 done