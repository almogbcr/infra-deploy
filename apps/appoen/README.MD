# Application & Docker

## Application

Flask application that runs on port 5050.

The application has three endpoints:

* `/` - Returns the application message, environment, and log level.
* `/health` - Returns the health status with HTTP 200.
* `/version` - Returns the version of the app.

## Dockerfile

* Used `python:3.14-slim` as the base image.
* Set the working directory to `/opt/infradeploy/flask`.
* Installed `requirements.txt` before copying the application code
  to take advantage of Docker's build cache.
* Used `--no-cache-dir` to avoid storing pip cache inside the image.
* Copied the application files using `COPY . .`.
* Used `EXPOSE 5050` to document the application port.
* Used `CMD` to start Gunicorn and bind it to `0.0.0.0:5050`.

## Local Testing

Run the following commands from the `app` directory.

Build the image:

```bash
docker build -t flask-app:local .
```

Run the container:

```bash
docker run -d --name flaskapp --rm -p 5050:5050 flask-app:local
```

Test the application endpoints:

```bash
curl -i http://localhost:5050/
curl -i http://localhost:5050/health
curl -i http://localhost:5050/version
```

Stop the container:

```bash
docker stop flaskapp
```