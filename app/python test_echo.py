import requests

resp = requests.post("http://127.0.0.1:5000/echo", json={"message": "Hello Sandeep!"})
print(resp.status_code)
print(resp.text)
