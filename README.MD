# Infrastructure Deployment - DevOps Assignment

## Overview

DevOps technical assignment - build and deploy Flask application while using modern tools and IaC

### Application

Flask application that runs on port 5050.

App has two endpoints:
 
* /       - returns "DevOps Assignment" 
* /health - returns a health status with HTTP 200.
 
For Docker setup and local testing, see [Application README](app/README.MD)

## CI - GitHub Actions

### Flask CI

The workflow is separated into 3 jobs:

**1. Changes**
- Checks if relevant files in the `app/` directory have changed.
- Excludes Markdown files.
- Runs in parallel with the Tests job.

**2. Tests**
- Uses Ruff to check Python code for common issues.
- Uses Pytest to run the application tests.
- Runs in parallel with the Changes job.

**3. Build**
- Runs after both jobs finish successfully, and only if relevant application files have changed.
- Builds the Flask Docker image.
- Runs the container and checks the `/health` endpoint.
- Pushes the image to Docker Hub if the health check passes.


