#!/bin/bash

WEB_DIR="/usr/share/nginx/html"
WORDPRESS_ZIP="latest.zip"
WORDPRESS_URL="https://wordpress.org/$WORDPRESS_ZIP"

echo "Updating system packages..."
sudo yum update -y

echo "Installing Nginx, PHP, and required extensions..."
sudo yum install -y nginx php php-fpm php-mysqlnd php-xml php-mbstring php-json unzip

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Configuring PHP to work with Nginx..."
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

echo "Downloading WordPress..."
cd "$WEB_DIR"
sudo wget -O "$WORDPRESS_ZIP" "$WORDPRESS_URL"

if [ -f "$WORDPRESS_ZIP" ]; then
    echo "Removing any existing WordPress directories..."
    sudo rm -rf "$WEB_DIR/wordpress"  # Remove previous WordPress folders if they exist

    echo "Extracting WordPress..."
    sudo unzip -o "$WORDPRESS_ZIP"

    echo "Moving WordPress files to the web directory..."
    sudo mv "$WEB_DIR/wordpress/"* "$WEB_DIR/"  # Move all files to the web root
    sudo rm -rf "$WEB_DIR/wordpress"  # Remove the now-empty directory
    sudo rm "$WORDPRESS_ZIP"  # Clean up the zip file after extraction
else
    echo "Error: Failed to download WordPress. Please check the download URL."
    exit 1
fi

echo "Setting correct permissions for WordPress files..."
sudo chown -R nginx:nginx "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

echo "Removing the default Nginx configuration to avoid conflicts..."
sudo rm -f /etc/nginx/conf.d/default.conf

echo "Creating a custom Nginx configuration for WordPress..."
sudo bash -c "cat > /etc/nginx/conf.d/wordpress.conf" <<EOL
server {
    listen 80;
    server_name _;

    root $WEB_DIR;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

echo "Configuring firewall to allow HTTP and HTTPS traffic."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Testing Nginx configuration"
sudo nginx -t

echo "Restarting Nginx to apply changes"
sudo systemctl restart nginx

echo "WordPress setup finished..."
echo "Visit http://10.0.5.10 to complete the WordPress installation."
