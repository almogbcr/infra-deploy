import os

from flask import Flask, jsonify

app = Flask(__name__)

APP_ENV = os.getenv("APP_ENV", "local")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
APP_MESSAGE = os.getenv("APP_MESSAGE", "Hello World")

@app.route("/")
def hello_world():
        return {
        "message": APP_MESSAGE,
        "environment": APP_ENV,
        "log_level": LOG_LEVEL
    }

@app.route("/health")
def status():
    return {"status": "healthy"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050)