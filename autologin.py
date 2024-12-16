#!/usr/bin/env python3
# Autologin OpnSense-CaptivePortal Python
# ---- Change to your configuration below ----
key_url = 'http://192.168.1.1/'  # Ip Address of your firewall, you want to log in
time_before_repeat = 30          # Time (seconds) between every check, if you are either connected to your firewall, or if you got logged out - default = 30
username = "username"            # Your Username
password = "password"            # And your password
# ----
# Only change anything below if you know what to do

from time import sleep
import requests
status_url = key_url + "api/captiveportal/access/status/0/"
login_url = key_url + "api/captiveportal/access/logon/0/"
headers = {'Referer':key_url,
           'Origin':key_url,
           'Priority':'u=1',
           'DNT':'1',
           'Connection':'keep-alive'}

payload = {'user':username, 'password':password}
# vielleicht parameters siehe wiki

headers_status = {'Referer':key_url,
                  'Origin':key_url,
                  'DNT':'1',
                  'Connection':'keep-alive'}
payload_status = {'user':'','password':''}

def user_input(error_input):
    while True:
        if error_input == "y" or "Y":
            print("INFO: CONTINUE")
            return True
        elif error_input == "n" or "N":
            print("INFO: EXIT")
            return False
        else:
            print("INFO: INPUT DOESNT MATCH")

def internet_connection_avaliable():
    try:
        requests.get(key_url)
        return True
    except Exception as e:
        print(f"INFO: CANT CONNECT TO FIREWALL: {e}")
        return False

def login_status_request_json():
    status_response = requests.post(status_url, headers=headers_status, data=payload_status)
    return status_response.json()

def login_status_request():
    status_response = requests.post(status_url, headers=headers_status, data=payload_status)
    return status_response


while True:
    # print(status_response.json())

    if not internet_connection_avaliable():
        print("INFO: NO CONNECTION")
    elif login_status_request().status_code == 200:
        if login_status_request_json()["clientState"] == "AUTHORIZED":
            print("INFO: LOGGED IN")
        else:
            login_request_response = requests.post(login_url, headers=headers, data=payload)
            print(login_request_response.json()["clientState"])
    else:
        print(f"ERROR: UNKNOWN HTTP response: {login_status_request().status_code}")
        if not user_input(str(input("Retry/Continue (y/n): "))):
            exit(1)
    sleep(time_before_repeat)