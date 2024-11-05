#!/bin/bash

# First stop any existing httpd process and clear up any existing pid
sudo systemctl stop httpd
sudo rm -f /var/run/httpd/httpd.pid

# Install Apache and required packages
sudo dnf update -y
sudo dnf install -y httpd wget unzip php php-json php-zip php-gd php-curl php-mbstring php-xml

# Install Grav CMS (using the zip package that doesn't require composer)
cd /tmp
wget https://getgrav.org/download/core/grav-admin/latest -O grav.zip
unzip grav.zip
sudo mv grav-admin /var/www/html/grav
sudo chown -R apache:apache /var/www/html/grav

# Configure Apache Virtual Host
sudo cat << EOF > /etc/httpd/conf.d/grav.conf
<VirtualHost *:80>
    ServerName 10.0.5.22
    DocumentRoot /var/www/html/grav
    <Directory /var/www/html/grav>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
        DirectoryIndex index.php
    </Directory>
</VirtualHost>
EOF

# Configure firewall if enabled
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

# Start and enable Apache
sudo systemctl enable httpd
sudo systemctl start httpd

echo "Installation complete. Please visit http://10.0.5.10 to complete the setup."
