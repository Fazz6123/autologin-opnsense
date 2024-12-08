# Autologin OpnSense Python
# v0.1
# ---- Change to your configuration below ----
key_url = 'http://172.16.0.254:8000/'
status_url = key_url + "api/captiveportal/access/status/0/"
login_url = key_url + "api/captiveportal/access/logon/0/"
time_before_repeat = 30
username = "peckfe"
password = "ygYD5)3T"
# ----
# Only change anything below if you know what to do

from time import sleep
import requests

#username = str(input("Username: "))
#password = str(input("Password: "))
login_status = False
headers = {'Referer':key_url,
           'Origin':key_url,
           'Priority':'u=1',
           'DNT':'1',
           'Connection':'keep-alive'}
payload = f"user={username}&password={password}"
# vielleicht parameters siehe wiki

headers_status = {'Referer':key_url,
                  'Origin':key_url,
                  'DNT':'1',
                  'Connection':'keep-alive'}
payload_status = "user=&password="
#payload_second = 'user=' + username + '&password=' + password
#payload = {'user':username, 'password':password}

while True:
    status_response = requests.post(status_url, headers=headers_status, data=payload_status)
    print(status_response.json())
    if login_status:
         pass
    else:
        login_request_response = requests.post(login_url, headers=headers, data=payload)
        print(login_request_response.json())
    sleep(time_before_repeat)

#r = requests.post(status_url, headers=headers, data=payload)