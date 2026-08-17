#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

# download apache
sudo apt-get install apache2 -y

# download mysql
sudo apt-get install mysql-server -y

sudo mysql

CREATE USER 'osticket'@'localhost' IDENTIFIED BY 'psg';

CREATE DATABASE osticket;

GRANT ALL PRIVILEGES ON osticket.* TO 'osticket'@'localhost';

FLUSH PRIVILEGES;

EXIT;

# download php

sudo apt install -y software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y


sudo apt update && sudo apt install -y \
  php-cli \
  php-apcu \
  libapache2-mod-php8.4 \
  php8.4-{ctype,fileinfo,gd,gettext,iconv,imap,intl,mbstring,mysql,opcache,phar,xml,zip}

echo "extension=apcu.so" | sudo tee /etc/php/8.4/mods-available/apcu.ini
sudo phpenmod apcu
sudo systemctl restart apache2

# download OSTicketing

sudo apt-get install -y unzip

sudo wget https://github.com/osTicket/osTicket/releases/download/v1.18.4/osTicket-v1.18.4.zip

unzip osTicket-v1.18.4.zip -d osTicket_temp

sudo mv /osTicket_temp/upload /var/www/html/osticket

sudo rm /var/www/html/index.html

cd /var/www/html/osticket
sudo cp include/ost-sampleconfig.php include/ost-config.php

sudo chown -R www-data:www-data /var/www/html/osticket/

rm -rf ~/osTicket_temp ~/osTicket-v1.18.4.zip

sudo chmod 0644 include/ost-config.php