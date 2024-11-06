#!/bin/bash

INDEX_FILE="index.html" 
WEB_DIR="/var/www/html" 

echo "Updating system packages..."
sudo yum update -y

echo "Installing Apache..."
sudo yum install -y httpd

echo "Starting and enabling Apache..."
sudo systemctl start httpd
sudo systemctl enable httpd

if [ -f "$INDEX_FILE" ]; then
    echo "Moving index.html to Apache web directory..."
    sudo cp "$INDEX_FILE" "$WEB_DIR"
else
    echo "Error: $INDEX_FILE not found. Please ensure the index.html file is in the same directory as this script."
    exit 1
fi

# Uncomment if you need to set permissions for the index file
# echo "Setting permissions for $WEB_DIR/$INDEX_FILE..."
# sudo chown apache:apache "$WEB_DIR/$INDEX_FILE"
# sudo chmod 644 "$WEB_DIR/$INDEX_FILE"

echo "Configuring firewall to allow HTTP and HTTPS traffic."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Testing Apache configuration"
sudo apachectl configtest

echo "Restarting Apache"
sudo systemctl restart httpd

echo "Apache web server setup finished..."
echo "The Webserver is now available on the server."
echo "Enjoy it B)"
