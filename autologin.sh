#!/bin/bash

# -------------------------------------------------
USERNAME="your username here"
PASSWORD="your password here"
FIREWALL_URL="http://172.16.0.254:8000/" # Replace with the Url of your Firewall captiveportal
sleep_time=20 # time until next automated check if connection still authorised, default = 20
# ----------------------------------

# It is not recommended to change anything below... (unless you know what you are doing)
# !Any recommended changes welcome!
STATUS_URL="${FIREWALL_URL}api/captiveportal/access/status/0/"
LOGIN_URL="${FIREWALL_URL}api/captiveportal/access/logon/0/"
VERSION="v1.0"
echo "INFO: Starting autologin.sh ; Version : ${VERSION}"

while true; do
      STATUS_RESPONSE=$(curl -s -X POST $STATUS_URL \
        -H 'Referer: http://172.16.0.254:8000/' \
        -H 'X-Requested-With: XMLHttpRequest' \
        -H 'Origin: http://172.16.0.254:8000' \
        -H 'DNT: 1' \
        -H 'Connection: keep-alive' \
        --data-raw 'user=&password=')

      CLIENT_STATE=$(echo "$STATUS_RESPONSE" | jq -r '.clientState')

      if [ "$CLIENT_STATE" == "AUTHORIZED" ]; then
        echo "INFO: logged in"
      else
        echo "INFO: Not logged in. Attempting to log in..."

        # Checking Network connection
        CONNECTION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $STATUS_URL)
          if [ "$CONNECTION_RESPONSE" -eq 000 ]; then
          echo "INFO: NO CONNECTION"
          fi

        while true; do
          CONNECTION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $STATUS_URL)

          if [ "$CONNECTION_RESPONSE" -eq 000 ]; then
            sleep 5
          else
            echo "INFO: Connection back"
            break
          fi
        done
        # Finish checking network connection
        LOGIN_RESPONSE=$(curl -s -X POST $LOGIN_URL \
        -H 'Referer: http://172.16.0.254:8000/' \
        -H 'X-Requested-With: XMLHttpRequest' \
        -H 'Origin: http://172.16.0.254:8000' \
        -H 'DNT: 1' \
        -H 'Connection: keep-alive' \
        -H 'Priority: u=1' \
        --data-raw "user=${USERNAME}&password=${PASSWORD}"
        )
        LOGIN_STATE=$(echo "$LOGIN_RESPONSE" | jq -r '.clientState')
        if [ "$LOGIN_STATE" == "AUTHORIZED" ]; then
          echo "INFO: Login successful"
        else
          echo "INFO: Login unsuccessful, check password or try again"
        fi
      fi
      sleep $sleep_time
done
