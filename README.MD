# Infrastructure Deployment - DevOps Assignment

## Overview
DevOps technical assignment - build and deploy Flask application while using modern tools and IaC

### Application

Flask application that runs on port 5050.

App has two endpoints:
 
 * / - returns "DevOps Assignment" 
 * /health - returns a health status with HTTP 200.
 
 ### Docker
* Used python:3.14-slim as the base image.
* Set the working directory to /opt/infradeploy/flask. The /opt directory is commonly used in Linux for optional or third-party applications.
* Copied and installed requirements.txt before copying the application code to take advantage of Docker's build cache and avoid reinstalling dependencies when only the application code changes.
* 