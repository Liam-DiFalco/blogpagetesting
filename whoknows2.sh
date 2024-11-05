#!/bin/bash
# Update package lists
sudo dnf update -y
# Install necessary packages
sudo dnf install -y httpd httpd-devel php php-fpm php-cli php-xml php-zip php-mbstring php-intl wget
# Download and unzip Grav
wget https://github.com/getgrav/grav/releases/download/1.7.27/grav-admin-v1.7.27.zip -O grav-admin.zip
unzip grav-admin.zip -d /var/www/html
sudo mv /var/www/html/grav-admin /var/www/html/grav
rm grav-admin.zip
# Set permissions
sudo chown -R apache:apache /var/www/html/grav
sudo chmod -R 755 /var/www/html/grav
# Configure Apache
cat << 'EOF' | sudo tee /etc/httpd/conf.d/grav.conf
<VirtualHost *:80>
    ServerName 10.0.5.10
    DocumentRoot /var/www/html/grav
    <Directory /var/www/html/grav>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/grav-error.log
    CustomLog /var/log/httpd/grav-access.log combined
</VirtualHost>
EOF
# Restart Apache and PHP-FPM
sudo systemctl restart httpd
sudo systemctl restart php-fpm
echo "Grav CMS installation completed. Please configure your domain or update your hosts file to test your new Grav site."
