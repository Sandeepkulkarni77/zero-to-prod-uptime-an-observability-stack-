from datetime import datetime
import socket
from flask import Flask, jsonify, request 

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to Sandeep's Flask app! Use /health to check status."

@app.route('/health')
def health_login():
    current_time = datetime.now().isoformat()
    host_name = socket.gethostname()

    data = {
        "status": "ok",
        "ts": current_time,
        "host": host_name
    }

    return jsonify(data)

@app.route('/echo', methods=['POST'])
def receive_data():
    incoming_data = request.get_json()  
    return jsonify(incoming_data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

