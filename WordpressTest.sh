#!/bin/bash

# Define variables
WEB_DIR="/usr/share/nginx/html"
WP_VERSION="latest"
WP_DB_FILE="database.sqlite"

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install required packages
echo "Installing required packages..."
sudo yum install -y nginx php php-fpm php-sqlite3

# Start and enable Nginx and PHP-FPM
echo "Starting and enabling Nginx and PHP-FPM..."
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Download and install WordPress
echo "Downloading WordPress..."
cd $WEB_DIR
sudo wget -O latest.zip https://wordpress.org/latest.zip
echo "Unzipping WordPress..."
sudo unzip -o latest.zip
sudo mv wordpress/* .
sudo rm -rf wordpress latest.zip

# Download and install SQLite Integration Plugin
echo "Downloading SQLite Integration Plugin..."
cd wp-content/plugins
sudo wget -O sqlite.zip https://downloads.wordpress.org/plugin/sqlite-integration.zip
sudo unzip -o sqlite.zip
sudo rm sqlite.zip

# Create the wp-config.php file
echo "Creating wp-config.php..."
cd $WEB_DIR
sudo cp wp-config-sample.php wp-config.php

# Update wp-config.php for SQLite
echo "Configuring wp-config.php for SQLite..."
sudo sed -i "/define('DB_NAME',/d" wp-config.php
sudo sed -i "/define('DB_USER',/d" wp-config.php
sudo sed -i "/define('DB_PASSWORD',/d" wp-config.php
sudo sed -i "/define('DB_HOST',/d" wp-config.php

# Add SQLite configuration
echo "// SQLite setup" | sudo tee -a wp-config.php
echo "if ( !defined('DB_NAME') ) {" | sudo tee -a wp-config.php
echo "    define('DB_NAME', '$WP_DB_FILE');" | sudo tee -a wp-config.php
echo "}" | sudo tee -a wp-config.php

# Create the SQLite database file
echo "Creating SQLite database file..."
sudo touch "$WEB_DIR/$WP_DB_FILE"
sudo chown nginx:nginx "$WEB_DIR/$WP_DB_FILE"

# Set permissions for WordPress files
echo "Setting permissions for WordPress files..."
sudo chown -R nginx:nginx $WEB_DIR
sudo find $WEB_DIR -type d -exec chmod 755 {} \;  # Directories
sudo find $WEB_DIR -type f -exec chmod 644 {} \;  # Files

# Restart Nginx and PHP-FPM
echo "Restarting Nginx and PHP-FPM..."
sudo systemctl restart nginx
sudo systemctl restart php-fpm

# Finish
echo "WordPress installation using SQLite completed successfully!"
echo "Visit your WordPress site at http://10.0.5.10 to finish the setup."
