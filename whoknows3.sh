#!/bin/bash

# Install Apache and required packages
sudo dnf update -y
sudo dnf install -y httpd wget unzip php php-json php-zip php-gd php-curl php-mbstring php-xml

# Install Grav CMS (using the zip package that doesn't require composer)
cd /tmp
wget https://getgrav.org/download/core/grav-admin/latest -O grav.zip
unzip grav.zip
sudo mv grav-admin /var/www/html/grav
sudo chown -R apache:apache /var/www/html/grav

# Configure Apache to listen on specific IP
sudo cat << EOF > /etc/httpd/conf.d/listen.conf
Listen 10.0.5.22:80
EOF

# Configure Apache Virtual Host
sudo cat << EOF > /etc/httpd/conf.d/grav.conf
<VirtualHost 10.0.5.22:80>
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

# Configure SELinux if enabled
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_unified 1

# Configure firewall if enabled
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

# Start and enable Apache
sudo systemctl enable httpd
sudo systemctl restart httpd

echo "Installation complete. Please visit http://10.0.5.10 to complete the setup."
