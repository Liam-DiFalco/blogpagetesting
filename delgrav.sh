#!/bin/bash

# Stop and disable Apache and PHP-FPM
sudo systemctl stop httpd
sudo systemctl disable httpd
sudo systemctl stop php-fpm
sudo systemctl disable php-fpm

# Remove the Grav installation directory
sudo rm -rf /var/www/html/grav

# Remove the Apache configuration file
sudo rm /etc/httpd/conf.d/grav.conf

# Remove the installed packages
sudo dnf remove -y httpd httpd-devel php php-fpm php-cli php-xml php-zip php-mbstring php-intl wget

# Clean up any remaining files or directories
sudo rm -rf /var/log/httpd/grav-*

echo "Grav CMS uninstallation completed."
