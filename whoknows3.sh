#!/bin/bash

# Stop any existing httpd process and clear up any existing pid
sudo systemctl stop httpd
sudo rm -f /var/run/httpd/httpd.pid

# Install the Remi repository for newer PHP versions
sudo dnf install -y dnf-utils
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.1 -y

# Install Apache and PHP 8.1 with required extensions
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
<VirtualHost *:443>
    ServerName 10.0.2.3
    DocumentRoot /var/www/html/grav
    <Directory /var/www/html/grav>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
        DirectoryIndex index.php
    </Directory>
    SSLEngine on
    SSLCertificateFile /path/to/your/certificate.crt
    SSLCertificateKeyFile /path/to/your/private.key
</VirtualHost>
EOF

# Configure firewall for HTTPS if enabled
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Start and enable Apache
sudo systemctl enable httpd
sudo systemctl start httpd

echo "Installation complete. Please visit https://10.0.5.10 to complete the setup."
