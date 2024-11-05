#!/bin/bash

# Variables
INDEX_FILE="index.html"  # custom index file in the same directory as this script
WEB_DIR="/usr/share/nginx/html"  # default web directory for Nginx

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install Nginx
echo "Installing Nginx..."
sudo yum install -y nginx

# Start and enable Nginx
echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Move custom index.html to the Nginx web directory
if [ -f "$INDEX_FILE" ]; then
    echo "Moving custom index.html to Nginx web directory..."
    sudo mv "$INDEX_FILE" "$WEB_DIR"
else
    echo "Error: $INDEX_FILE not found. Please ensure the index.html file is in the same directory as this script."
    exit 1
fi

# Set file permissions for web content
echo "Setting permissions for $WEB_DIR/$INDEX_FILE..."
sudo chown nginx:nginx "$WEB_DIR/$INDEX_FILE"
sudo chmod 644 "$WEB_DIR/$INDEX_FILE"

# Configure firewall to allow HTTP and HTTPS traffic only
echo "Configuring firewall to allow HTTP and HTTPS traffic..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Restart Nginx to apply changes
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Final status message
echo "Nginx web server setup complete with firewall rules for HTTP and HTTPS access."
echo "Your custom index.html is now available on the server."
