#!/bin/bash


# install mysql 8.0
cd /tmp && \
curl -OL https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb && \
sudo dpkg -i mysql-apt-config* && \
sudo apt-get update && \
sudo apt-get -y install mysql-server -y

# setup logging
sudo chmod -R 777 /var/log/mysql
sudo mysql -uroot -e "SET GLOBAL local_infile = 1;"
sudo mysql -uroot -e "SET GLOBAL slow_query_log_file ='/var/log/mysql/slow-query.log';"
sudo mysql -uroot -e "SET GLOBAL slow_query_log = 1;"
sudo mysql -uroot -e "SET GLOBAL long_query_time = 0;"
sudo mysql -uroot -e "SET long_query_time = 0;"