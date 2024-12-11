# Autologin OpnSense-CaptivePortal Python
# ---- Change to your configuration below ----
key_url = 'http://192.168.1.1/' # Ip Address of your firewall, you want to log in
time_before_repeat = 30          # Time (seconds) between every check, if you are either connected to your firewall, or if you got logged out - default = 30
username = "username"            # Your Username
password = "password123!"        # And your password
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



while True:
    status_response = requests.post(status_url, headers=headers_status, data=payload_status)
    list_status_response = status_response.json()
    # print(status_response.json())

    if status_response.status_code == 000:
        print("INFO: NO CONNECTION")
    elif status_response.status_code == 200:

        if list_status_response["clientState"] == "AUTHORIZED":
            pass
        else:
            login_request_response = requests.post(login_url, headers=headers, data=payload)
            print(login_request_response.json()["clientState"])
    else:
        print(f"ERROR: UNKNOWN HTTP response: {status_response.status_code}")
        if not user_input(str(input("Retry/Continue (y/n): "))):
            exit(1)
    sleep(time_before_repeat)