#!/bin/bash

WEB_DIR="/usr/share/nginx/html"
CMSIMPLE_ZIP="CMSimple_XH-1.7.5.zip"
CMSIMPLE_URL="https://www.cmsimple.org/en/?download=$CMSIMPLE_ZIP"

echo "Updating system packages..."
sudo yum update -y

echo "Installing Nginx and PHP..."
sudo yum install -y nginx php php-fpm unzip

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Configuring PHP to work with Nginx..."
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

echo "Downloading CMSimple..."
wget -O "$CMSIMPLE_ZIP" "$CMSIMPLE_URL"

if [ -f "$CMSIMPLE_ZIP" ]; then
    echo "Extracting CMSimple to the web directory..."
    sudo unzip -o "$CMSIMPLE_ZIP" -d /tmp/cmsimple
    sudo cp -r /tmp/cmsimple/* "$WEB_DIR/"
    sudo rm -rf /tmp/cmsimple "$CMSIMPLE_ZIP"
else
    echo "Error: Failed to download CMSimple. Please check the download URL."
    exit 1
fi

echo "Configuring file permissions for CMSimple..."
sudo chown -R nginx:nginx "$WEB_DIR"
sudo chmod -R 755 "$WEB_DIR"

echo "Removing the default Nginx configuration to avoid conflicts..."
sudo rm -f /etc/nginx/conf.d/default.conf

echo "Configuring Nginx for CMSimple..."
sudo bash -c "cat > /etc/nginx/conf.d/cmsimple.conf" <<EOL
server {
    listen 80;
    server_name _;

    root $WEB_DIR;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
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

echo "CMSimple setup finished..."
echo "CMSimple should now be available on the server."
echo "Visit http://<your-server-ip> to access CMSimple."
