#!/bin/bash

# Deploy script for the Flask app

# Step 1: Pull the latest code from the repository
git pull origin main

# Step 2: Build the Docker image
docker build -t flask-app:latest .

# Step 3: Stop and remove the existing container (if it exists)
docker stop flask-app-container || true
docker rm flask-app-container || true

# Step 4: Run the new container
docker run -d --name flask-app-container -p 5000:5000 flask-app:latest

# Step 5: Check the logs for any errors
docker logs flask-app-container

echo "Deployment completed. The app should be accessible at http://localhost:5000"
