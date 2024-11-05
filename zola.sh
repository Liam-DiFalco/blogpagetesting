#!/bin/bash

# Variables
SITE_NAME="my-zola-site"
SITE_DIR="/usr/share/nginx/html/$SITE_NAME"
ZOLA_VERSION="0.17.0"  # Check for the latest version and update if needed

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

# Install dependencies
echo "Installing required packages..."
sudo yum install -y git wget

# Download and install Zola
if ! command -v zola &> /dev/null; then
    echo "Zola not found. Installing Zola version $ZOLA_VERSION..."
    wget https://github.com/getzola/zola/releases/download/v$ZOLA_VERSION/zola-v$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz
    tar -xzf zola-v$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz
    sudo mv zola /usr/local/bin/
    rm zola-v$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz
else
    echo "Zola is already installed."
fi

# Create a new Zola site
echo "Creating new Zola site in $SITE_DIR..."
mkdir -p $SITE_DIR
cd $SITE_DIR
zola init .

# Build the Zola site
echo "Building the Zola site..."
zola build

# Set permissions
echo "Setting permissions for $SITE_DIR..."
sudo chown -R nginx:nginx $SITE_DIR
sudo find $SITE_DIR -type d -exec chmod 755 {} \;  # Directories
sudo find $SITE_DIR -type f -exec chmod 644 {} \;  # Files

# Configure Nginx to serve the Zola site
echo "Configuring Nginx..."
cat <<EOL | sudo tee /etc/nginx/conf.d/zola.conf
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
echo "Zola installation and setup completed!"
echo "Visit your site at http://10.0.5.10."
