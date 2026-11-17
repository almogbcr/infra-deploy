 ### Docker
* Used python:3.14-slim as the base image.
* Set the working directory to /opt/infradeploy/flask. The /opt directory is commonly used in Linux for optional or third-party applications.
* Copied and installed requirements.txt before copying the application code to take advantage of Docker's build cache and avoid reinstalling dependencies when only the application code changes.
* Copied the application files into the image using COPY . ..
* Used EXPOSE 5050 to document the port used by the application.
* Used CMD to start Gunicorn, bind it to port 5050, and run the Flask application from app.py.

### Docker Image Testing
Built and tested the docker image locally using docker

* build the image using Docker build
```bash
docker build -t flask-app:1.0 .
```
* run docker image as detach Docker run
```bash
docker run -d --name flaskapp -p 5050:5050 flask-app:1.0 
```
* Tested the app with curl
```bash
curl -i http://localhost:5050/health
```
* HTTP 200 With a healthy status