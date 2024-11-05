#!/bin/bash

# Install Apache and required packages
sudo dnf update -y
sudo dnf install -y httpd wget unzip php php-json php-zip php-gd php-curl php-mbstring php-xml

# Install Grav CMS
cd /tmp
wget https://getgrav.org/download/core/grav/latest -O grav.zip
unzip grav.zip
sudo mv grav /var/www/html/
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

# Configure SELinux if enabled
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_unified 1

# Start and enable Apache
sudo systemctl enable httpd
sudo systemctl start httpd

echo "Installation complete. Please visit http://localhost to complete the setup."
