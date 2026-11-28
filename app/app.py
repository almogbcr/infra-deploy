import os

from flask import Flask

app = Flask(__name__)

APP_ENV = os.getenv("APP_ENV", "local")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
APP_MESSAGE = os.getenv("APP_MESSAGE", "Hello World")

app.logger.setLevel(LOG_LEVEL.upper())

@app.route("/")
def hello_world():
        app.logger.debug("Home endpoint requested")
        return {
        "message": APP_MESSAGE,
        "environment": APP_ENV,
        "log_level": LOG_LEVEL
    }

@app.route("/health")
def status():
    return {"status": "healthy"}, 200

@app.route("/version")
def version():
    return {"version": "4.2"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050)