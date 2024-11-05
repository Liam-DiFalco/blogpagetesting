#!/bin/bash

# Install Apache
sudo dnf update -y
sudo dnf install -y httpd

# Install Grav CMS
sudo wget -O grav.zip https://github.com/getgrav/grav/releases/latest/download/grav-admin.zip
sudo unzip grav.zip -d /var/www/html/
sudo chown -R apache:apache /var/www/html/grav

# Configure Apache
sudo cat << EOF > /etc/httpd/conf.d/grav.conf
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

sudo systemctl enable httpd
sudo systemctl start httpd
