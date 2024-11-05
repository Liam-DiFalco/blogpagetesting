#!/bin/bash


INDEX="index.html" 
WEB_DIR="/usr/share/nginx/html" 

echo "Get ready, were updating the system packages..."
sudo yum update -y

echo "Installing Best local web hoster: Nginx..."
sudo yum install -y nginx

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

if [ -f "$INDEX" ]; then
    echo "Moving index.html to Nginx web directory..."
    sudo mv "$INDEX" "$WEB_DIR"
else
    echo "Error: $INDEX not found. Please make sure the index.html file is in the same directory as this script goober."
    exit 1
fi

echo "Setting permissions for $WEB_DIR/$INDEX..."
sudo chown nginx:nginx "$WEB_DIR/$INDEX"
sudo chmod 644 "$WEB_DIR/$INDEX_FILE"

echo "Configuring firewall RIGHT NOW!!!!!!!!!!!"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Testing Nginx NOW!!!!"
sudo nginx -t

echo "Restarting Nginx ;)"
sudo systemctl restart nginx

echo "Nginx web server finally complete with firewall rules B)"
echo "index.html is now available on the server."
echo "Enjoy!"
