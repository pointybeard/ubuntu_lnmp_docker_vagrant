#!/usr/bin/env bash

if [ -z "${BASH_VERSINFO}" ] || [ -z "${BASH_VERSINFO[0]}" ] || [ ${BASH_VERSINFO[0]} -lt 4 ]; then
    echo "This script requires Bash version >= 4\n\n"; exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get clean && \
apt-get update -yq && \
apt-get upgrade -yq && \
apt-get install -y apt-utils locales

localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

## Basics
apt-get install -yq build-essential module-assistant linux-headers-virtual software-properties-common ca-certificates dirmngr apt-transport-https man-db keychain acpid dkms tree zip unzip wget ruby curl acl iproute2 git nano

## Networking
sysctl net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv4.icmp_echo_ignore_all=0

## PHP (8.1)
apt-get remove --purge '^php*' -yq
add-apt-repository -y ppa:ondrej/php
apt-get update -yq
apt-get install -yq php php-pear php-curl php-dev php-gd php-mbstring php-zip php-mysql php-xml php-json php-pcov php-xml php-intl
systemctl start php8.1-fpm.service && systemctl enable php8.1-fpm.service

## NGINX
add-apt-repository -y ppa:ondrej/nginx
apt-get update -yq
apt-get install -yq python3-certbot-nginx nginx php-fpm ssl-cert
apt-get remove --purge '^apache2.*' -yq
systemctl start nginx.service && systemctl enable nginx.service

rmdir /etc/nginx/conf.d
rm /etc/nginx/fastcgi_params
rm -R /etc/nginx/sites-available
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/nginx.conf

ln -sf /vagrant/conf/nginx/nginx.conf /etc/nginx/
ln -sf /vagrant/conf/nginx/conf.d /etc/nginx/
ln -sf /vagrant/conf/nginx/sites-available /etc/nginx/
ln -sf /vagrant/conf/nginx/fastcgi_params /etc/nginx/
ln -sf /vagrant/conf/nginx/cors_options_headers /etc/nginx/
ln -sf /vagrant/conf/nginx/cors_headers /etc/nginx/

ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

rm -R /var/www
ln -s /vagrant/www /var/
ln -s /vagrant/sources /var/

## MariaDB
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup -o mariadb_repo_setup
bash mariadb_repo_setup --mariadb-server-version=10.7
apt-get update -yq
apt-get install -yq mariadb-server mariadb-client
systemctl start mariadb.service && systemctl enable mariadb.service

## Composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
ln -sf /usr/local/bin/composer /usr/bin/
rm composer-setup.php

## Hub
wget https://github.com/github/hub/releases/download/v2.14.2/hub-linux-arm64-2.14.2.tgz && \
tar -zxf hub-linux-arm64-2.14.2.tgz && \
mv hub-linux-arm64-2.14.2/bin/hub /usr/bin/hub && \
chmod 755 /usr/bin/hub && \
rm -R hub-linux-arm64-2.*

## NodeJS
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
apt-get install -yq nodejs

## PECL/Pickle
wget https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar
mv pickle.phar /usr/local/bin/pickle
chmod +x /usr/local/bin/pickle

## gh (GitHub)
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C99B11DEB97541F0
apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
apt-add-repository -y https://cli.github.com/packages
apt-get update -yq
apt-get install -yq gh

## Vagrant user bash aliases
rm -rf /home/vagrant/.bash_aliases && \
cp /vagrant/conf/bash_aliases /home/vagrant/.bash_aliases

## Vagrant root bash aliases
rm -rf /root/.bash_aliases && \
cp /vagrant/conf/bash_aliases_root /root/.bash_aliases
