#!/bin/bash

INDEX_FILE="index.html"  # custom index file in the same directory as this script
WEB_DIR="/usr/share/nginx/html"  # default web directory for Nginx

echo "Updating system packages..."
sudo yum update -y

echo "Installing Nginx..."
sudo yum install -y nginx

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

if [ -f "$INDEX_FILE" ]; then
    echo "Moving index.html to Nginx web directory..."
    sudo mv "$INDEX_FILE" "$WEB_DIR"
else
    echo "Error: $INDEX_FILE not found. Please ensure the index.html file is in the same directory as this script."
    exit 1
fi

echo "Setting permissions for $WEB_DIR/$INDEX_FILE..."
sudo chown nginx:nginx "$WEB_DIR/$INDEX_FILE"
sudo chmod 644 "$WEB_DIR/$INDEX_FILE"

echo "Configuring firewall to allow HTTP and HTTPS traffic."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Testing Nginx configuration"
sudo nginx -t

echo "Restarting Nginx"
sudo systemctl restart nginx

echo "Nginx web server setup finished..."
echo "The Webserver is now available on the server."
echo "Enjoy it B)"
