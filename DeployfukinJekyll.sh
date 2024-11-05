#!/bin/bash

# Variables
SITE_DIR="/usr/share/nginx/html/my_jekyll_site"

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install dependencies
echo "Installing required packages..."
sudo yum install -y gcc make curl gpg

# Install RVM
echo "Installing RVM..."
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

# Install the latest Ruby version
echo "Installing the latest Ruby..."
rvm install ruby --latest
rvm use ruby --default

# Install Bundler and Jekyll
echo "Installing Bundler and Jekyll..."
gem install bundler
gem install jekyll

# Create Jekyll site
echo "Creating new Jekyll site in $SITE_DIR..."
jekyll new $SITE_DIR

# Build the site
echo "Building the Jekyll site..."
cd $SITE_DIR
jekyll build

# Set permissions
echo "Setting permissions for $SITE_DIR..."
sudo chown -R nginx:nginx $SITE_DIR
sudo find $SITE_DIR -type d -exec chmod 755 {} \;  # Directories
sudo find $SITE_DIR -type f -exec chmod 644 {} \;  # Files

# Configure Nginx to serve the Jekyll site
echo "Configuring Nginx..."
cat <<EOL | sudo tee /etc/nginx/conf.d/jekyll.conf
server {
    listen 80;
    server_name 10.0.5.10;

    root $SITE_DIR/_site;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.html$ {
        expires -1;
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
echo "Jekyll installation and setup completed!"
echo "Visit your site at http://10.0.5.10."
