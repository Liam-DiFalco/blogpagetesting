#!/bin/bash

# Install Apache
sudo apt-get update
sudo apt-get install -y apache2 wget

# Install Grav CMS
sudo wget -O grav.zip https://github.com/getgrav/grav/releases/latest/download/grav-admin.zip
sudo unzip grav.zip -d /var/www/html/
sudo chown -R www-data:www-data /var/www/html/grav

# Configure Apache
sudo cat << EOF > /etc/apache2/sites-available/grav.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html/grav
    <Directory /var/www/html/grav>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite grav.conf
sudo systemctl restart apache2
