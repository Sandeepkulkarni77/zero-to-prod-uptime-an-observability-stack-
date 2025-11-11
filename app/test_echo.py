import requests

url = "http://127.0.0.1:5000/echo"
payload = {"message": "Hello Sandeep"}

print("Sending POST request to:", url)

try:
    response = requests.post(url, json=payload)
    print("Response status:", response.status_code)
    print("Response text:", response.text)
except Exception as e:
    print("⚠️ Error:", e) 
