#!/bin/bash

# Update package lists
sudo dnf update -y

# Install Nginx
sudo dnf install -y nginx

# Install PHP and necessary extensions
sudo dnf install -y php php-fpm php-cli php-xml php-zip php-mbstring php-intl

# Download and unzip Grav
wget https://getgrav.org/download/core/grav-admin/latest -O grav-admin.zip
unzip grav-admin.zip -d /var/www/html
sudo mv /var/www/html/grav-admin /var/www/html/grav
rm grav-admin.zip

# Set permissions
sudo chown -R nginx:nginx /var/www/html/grav
sudo chmod -R 755 /var/www/html/grav

# Configure Nginx
cat << 'EOF' | sudo tee /etc/nginx/conf.d/grav.conf
server {
    listen 80;

    server_name your_domain.com;

    root /var/www/html/grav;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php-fpm/www.sock;
    }
}
EOF

# Restart Nginx and PHP-FPM
sudo systemctl restart nginx
sudo systemctl restart php-fpm

echo "Grav CMS installation completed. Please configure your domain or update your hosts file to test your new Grav site."
