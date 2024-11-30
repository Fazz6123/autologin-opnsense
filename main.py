from time import sleep
import requests

key_url = "http://172.16.0.254:8000/"
status_url = key_url + "api/captiveportal/access/status/0/"
login_url = key_url + "api/captiveportal/access/logon/0/"
username = str(input("Username: "))
password = str(input("Password: "))

headers = {'Referer':key_url,'Origin':key_url, 'Priority':'u=1'}
payload = {'user':username, 'password':password}

while True:
    r = requests.post(status_url, headers=headers, data=payload)

    r = requests.post(login_url, headers=headers, data=payload)
    print(r.json())
    sleep(30)