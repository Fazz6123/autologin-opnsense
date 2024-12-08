#!/bin/bash

# Still missing: Auto logoff after time, detailed information when running the script, whithout user and pass
# Adding 2 arguments after the initial script launched
if [ "$#" -ne 2 ]; then 
echo "Wrong Usage: $0 <username> '<password>'   <-- Take care: ' needed if password contains certain characters"
exit 1
fi

# Store the added phrases into variables
version=0.3
USERNAME="$1"
PASSWORD="$2"
STATUS_URL="http://172.16.0.254:8000/api/captiveportal/access/status/0/"
LOGIN_URL="http://172.16.0.254:8000/api/captiveportal/access/logon/0/"
LOGOFF_URL="http://172.16.0.254:8000/api/captiveportal/access/logoff/0/"
FIRST_CYCLE="1"

echo "Starting autologin v0.3.beta"
echo "init: username:$USERNAME and password:$PASSWORD"


# Check if user is still logged in
while true; do 

    STATUS_RESPONSE=$(curl -s -X POST $STATUS_URL \
        -H 'Referer: http://172.16.0.254:8000/' \
        -H 'X-Requested-With: XMLHttpRequest' \
        -H 'Origin: http://172.16.0.254:8000' \
        -H 'DNT: 1' \
        -H 'Connection: keep-alive' \
        --data-raw 'user=&password=')

    CLIENT_STATE=$(echo $STATUS_RESPONSE | jq -r '.clientState')


    if [ "$CLIENT_STATE" == "AUTHORIZED" ]; then
        if [ "$FIRST_CYCLE" -eq 1 ]; then 
            echo "INFO: Already logged in"
            echo "INFO: Monitoring connection"
            FIRST_CYCLE="0"
        else 
            echo "INFO: Still Checking"
        fi
    else
        echo "INFO: Not logged in. Attempting to log in..."

    # Check if Internet connection even exists, if not var WAIT_CONNECTION set to 1   
    CONNECTION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $STATUS_URL)

    if [ "$CONNECTION_RESPONSE" -eq 000 ]; then
        echo "INFO: NO CONNECTION"
        WAIT_CONNECTION="1"

            # 000 Error response = no Internet connection to the network --> prints out a message
        
    while [ "$WAIT_CONNECTION" -eq 1 ]; do

        # while loop for var=1 when connection lost until conection again gained

    CONNECTION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $STATUS_URL)

    if [ "$CONNECTION_RESPONSE" -eq 000 ]; then
        echo "INFO: NO CONNECTION"
        sleep 5
    else
        echo "INFO: CONNECTION BACK"
        WAIT_CONNECTION="0"
        # maybe use break instead of a variable
    fi

    done



    else
    echo "INFO: Connected"        
    fi
    echo "INFO: Connected again"


    # Real login Packages are beein sent
        LOGIN_RESPONSE=$(curl -s -X POST $LOGIN_URL \
        -H 'Referer: http://172.16.0.254:8000/' \
        -H 'X-Requested-With: XMLHttpRequest' \
        -H 'Origin: http://172.16.0.254:8000' \
        -H 'DNT: 1' \
        -H 'Connection: keep-alive' \
        -H 'Priority: u=1' \
        --data-raw "user=$USERNAME&password=$PASSWORD"
        )

        LOGIN_STATE=$(echo $LOGIN_RESPONSE | jq -r '.clientState')
        LOGIN_IP_ADRESS=$(echo $LOGIN_RESPONSE | jq -r '.ipAddress')

        #debug echos
        #echo "STATUS_RESPONSE= $STATUS_RESPONSE"
        #echo "CLIENT_STATE= $CLIENT_STATE"
        #echo "LOGIN_RESPONSE= $LOGIN_RESPONSE"
        #echo "LOGIN_STATE= $LOGIN_STATE"


    if [ "$LOGIN_STATE" == "AUTHORIZED" ]; then
        echo "INFO: Login succesful with IP: $LOGIN_IP_ADRESS"
    else
        echo "INFO: Login failed"


        fi
    fi

sleep 25
done
