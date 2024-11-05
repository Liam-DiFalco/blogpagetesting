#!/bin/bash

# Variables
SITE_DIR="/usr/share/nginx/html/grav"

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

# Install required packages
echo "Installing required packages..."
sudo yum install -y git unzip

# Create a new directory for Grav
echo "Creating directory for Grav..."
mkdir -p $SITE_DIR

# Download and extract Grav
echo "Downloading and extracting Grav..."
wget -O grav.zip https://getgrav.org/downloads/grav-admin/grav-admin.zip
unzip grav.zip -d $SITE_DIR
rm grav.zip

# Set permissions
echo "Setting permissions for $SITE_DIR..."
sudo chown -R nginx:nginx $SITE_DIR
sudo find $SITE_DIR -type d -exec chmod 755 {} \;  # Directories
sudo find $SITE_DIR -type f -exec chmod 644 {} \;  # Files

# Configure Nginx to serve Grav
echo "Configuring Nginx..."
cat <<EOL | sudo tee /etc/nginx/conf.d/grav.conf
server {
    listen 80;
    server_name 10.0.5.10;  # Change this to your server's IP or domain name

    root $SITE_DIR;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;  # Adjust this if you're using a different PHP setup
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|ico)$ {
        expires 30d;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Restart Nginx to apply changes
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Finish
echo "Grav installation and setup completed!"
echo "Visit your site at http://10.0.5.10."
