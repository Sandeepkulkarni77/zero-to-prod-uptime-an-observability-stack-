#!/usr/bin/env python3
import time
import requests
import os

URL = "http://localhost:5000/health"

def main():
    start = time.time()
    try:
        resp = requests.get(URL, timeout=3)
        latency_ms = (time.time() - start) * 1000

        print("Host:", os.uname()[1])
        print("Status code:", resp.status_code)
        print("Latency (ms):", round(latency_ms, 2))
        print("Response body:", resp.text)
    except Exception as e:
        latency_ms = (time.time() - start) * 1000
        print("REQUEST FAILED")
        print("Latency (ms):", round(latency_ms, 2))
        print("Error:", repr(e))

if __name__ == "__main__":
    main()




