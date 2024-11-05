#!/bin/bash

# Variables
SITE_NAME="my-hugo-site"
SITE_DIR="/usr/share/nginx/html/$SITE_NAME"

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install dependencies
echo "Installing required packages..."
sudo yum install -y git wget

# Install Hugo
echo "Installing Hugo..."
sudo yum install -y hugo

# Create a new Hugo site
echo "Creating new Hugo site in $SITE_DIR..."
mkdir -p $SITE_DIR
cd $SITE_DIR
hugo new site .

# Add a theme (example theme: Ananke)
echo "Adding Hugo theme..."
git init
git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke

# Configure the site to use the theme
echo "Configuring Hugo to use Ananke theme..."
cat <<EOL > config.toml
baseURL = "http://10.0.5.10/"
languageCode = "en-us"
title = "My Hugo Site"
theme = "ananke"
EOL

# Create a sample post
echo "Creating a sample post..."
hugo new posts/my-first-post.md

# Build the Hugo site
echo "Building the Hugo site..."
hugo

# Set permissions
echo "Setting permissions for $SITE_DIR..."
sudo chown -R nginx:nginx $SITE_DIR
sudo find $SITE_DIR -type d -exec chmod 755 {} \;  # Directories
sudo find $SITE_DIR -type f -exec chmod 644 {} \;  # Files

# Configure Nginx to serve the Hugo site
echo "Configuring Nginx..."
cat <<EOL | sudo tee /etc/nginx/conf.d/hugo.conf
server {
    listen 80;
    server_name 10.0.5.10;

    root $SITE_DIR/public;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|ico)$ {
        expires 30d;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Finish
echo "Hugo installation and setup completed!"
echo "Visit your site at http://10.0.5.10."
