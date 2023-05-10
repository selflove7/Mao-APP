#!/bin/bash

######################################################################
# Purpose: Deploying and running the "maoApp" application using PM2
# Version: 14.16.1
# Created Date: 2023-05-10
# Modified Date: [Insert Date]
# Author: Mao
######################################################################

# START #

set -e

# Set variables

ARTIFACTS_DIR="/root/artifacts"
APP_DIR="/root/maoApp"

# Kill any existing application running on port 3000 and delete all pm2 processes

sudo kill -9 $(sudo lsof -t -i:3000) || true
pm2 delete all || true

# Update the system and install necessary packages if not installed

sudo yum update -y
sudo yum install -y git

# Define version numbers

NODE_VERSION=14.16.1
PM2_VERSION=5.1.0

# Install nvm and Node.js

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

cd /usr/local/src

# Remove existing Node.js tarball if present

if [ -e "/usr/local/src/node-v14.16.1-linux-x64.tar.xz" ]; then
    rm /usr/local/src/node-v14.16.1-linux-x64.tar.xz
    echo "Node.js tarball deleted"
else
    echo "Node.js tarball not found"
fi

# Download and extract Node.js

sudo wget https://nodejs.org/dist/v14.16.1/node-v14.16.1-linux-x64.tar.xz
sudo tar -xJf node-v14.16.1-linux-x64.tar.xz

# Remove existing Node.js directory if present

if [ -d "/opt/nodejs/node-v14.16.1-linux-x64" ]; then
    sudo rm -rf /opt/nodejs/node-v14.16.1-linux-x64
    echo "Directory removed"
fi

# Remove old Node.js and NPM binaries

sudo rm -f /usr/local/bin/node
sudo rm -f /usr/local/bin/npm

# Move extracted Node.js directory to /opt/nodejs and create symbolic links

sudo mv node-v14.16.1-linux-x64 /opt/nodejs
sudo ln -s /opt/nodejs/bin/node /usr/local/bin/node
sudo ln -s /opt/nodejs/bin/npm /usr/local/bin/npm

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION

# Create a new directory and switch to it

if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
    echo "maoApp folder deleted"
else
    echo "maoApp folder not found"
fi

mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Clone the repositories

git clone https://github.com/mohit355/maoFrontend.git  "$APP_DIR/maoFrontend"
git clone https://github.com/mohit355/maoBackend.git "$APP_DIR/maoBackend"

# Install dependencies and build the frontend

cd "$APP_DIR/maoFrontend"
npm install
npm run build

# Install dependencies for the backend

cd "$APP_DIR/maoBackend"
npm install
 
# Install pm2 if not already installed

if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2@$PM2_VERSION
fi

export PATH=$PATH:/opt/nodejs/lib/node_modules/pm2/bin/

# Navigate to the project directory and start the frontend with pm2

cd "$APP_DIR/maoFrontend"

pm2 start npm --name "maoFrontend" -- run dev

# Save the current pm2 configuration to be automatically started on system boot

pm2 save

# Create artifact of the maoApp directory

mkdir -p "$ARTIFACTS_DIR"
zip -r "$ARTIFACTS_DIR/maoApp_$(date +%Y%m%d%H%M%S).zip" "$APP_DIR"

# tar -czvf "$ARTIFACTS_DIR/maoApp.tar.gz" "$APP_DIR"

# Fetch the external IP address

IP_ADDRESS=$(curl -sSf icanhazip.com)

# Define the URL for checking the Node.js application

APP_URL="http://$IP_ADDRESS:3000"

# Make a request to the application and check the response

response=$(curl -sSf "$APP_URL")
if [ $? -eq 0 ]; then
    echo "Node.js application is up and running"
else
    echo "Node.js application is not responding"
fi

# END #
