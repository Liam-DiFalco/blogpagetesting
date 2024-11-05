#!/bin/bash

# Variables
SITE_DIR="/usr/share/nginx/html/my_jekyll_site"

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install dependencies
echo "Installing required packages..."
sudo yum install -y gcc make curl git zlib-devel libffi-devel openssl-devel

# Install rbenv and ruby-build
echo "Installing rbenv..."
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

echo "Installing ruby-build..."
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 3.0.0
echo "Installing Ruby 3.0.0..."
rbenv install 3.0.0
rbenv global 3.0.0

# Verify Ruby installation
ruby -v

# Install Bundler and Jekyll
echo "Installing Bundler..."
gem install bundler

echo "Installing Jekyll..."
gem install jekyll

# Create Jekyll site
echo "Creating new Jekyll site in $SITE_DIR..."
jekyll new $SITE_DIR

# Build the site
echo "Building the Jekyll site..."
cd $SITE_DIR
jekyll build

# Set permissions
echo "Setting permissions for $SITE_DIR..."
sudo chown -R nginx:nginx $SITE_DIR
sudo find $SITE_DIR -type d -exec chmod 755 {} \;  # Directories
sudo find $SITE_DIR -type f -exec chmod 644 {} \;  # Files

# Configure Nginx to serve the Jekyll site
echo "Configuring Nginx..."
cat <<EOL | sudo tee /etc/nginx/conf.d/jekyll.conf
server {
    listen 80;
    server_name 10.0.5.10;

    root $SITE_DIR/_site;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.html$ {
        expires -1;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|ico)$ {
        expires 30d;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Finish
echo "Jekyll installation and setup completed!"
echo "Visit your site at http://10.0.5.10."
